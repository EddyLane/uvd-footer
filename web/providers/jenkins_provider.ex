defmodule UvdFooter.JenkinsProvider do

  import String, only: [replace_prefix: 3, replace_suffix: 3]

  alias Timex.DateFormat
  alias Timex.Date
  alias Poison.Parser

  require Record

  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")

  def get_latest(amount) do
    %{ body: xml_string } = HTTPotion.get("http://#{auth_string}@#{ci_url}/rssLatest")

    xml_string |> generate_response(amount)
  end

  def generate_response(xml_string, amount) do
    xml_string
     |> from_string
     |> xpath("//entry")
     |> Enum.map(&parse_entries/1)
     |> Enum.sort(&entries_by_last_updated/2)
     |> Enum.take(amount)
     |> Enum.map(&replace_api_job_link/1)
     |> Enum.map(&(add_in_extra_job_data(&1, :job_link)))
     |> Enum.map(&replace_api_build_link/1)
     |> Enum.map(&(add_in_extra_job_data(&1, :build_link)))
     |> Enum.map(&sanitize_job_data/1)
     |> Enum.map(&replace_culprits/1)
     |> Enum.map(&add_formatted_date_string/1)
     |> Enum.map(&convert_to_job_struct/1)
  end

  def parse_entries(entries) do xmlElement(entries, :content) |> parse end
  def auth_string do "#{ci_user}:#{ci_token}" end
  def ci_url do Application.get_env(:uvd_footer, :ci_url) end
  def ci_token do Application.get_env(:uvd_footer, :ci_token) end
  def ci_user do Application.get_env(:uvd_footer, :ci_user) end

  def add_percentage(job) do

    {:ok, published} =  get_updated_datetime(job, :published)

    {:ok, expected_complete} = Date.add(published, { 0, 0, Map.get(job, :estimatedDuration) })

    {:ok, formatted} = expected_complete |> DateFormat.format("%Y-%m-%d %H:%I", :strftime)

    job |> Map.put(:estimatedCompletion, formatted)

  end

  def entries_by_last_updated(first, second) do
    {:ok, first_date} =  get_updated_datetime(first, :updated)
    {:ok, second_date} = get_updated_datetime(second, :updated)

    Date.compare(first_date, second_date) == 1
  end

  defp add_formatted_date_string(job) do

    {:ok, datetime} =  get_updated_datetime(job, :published)
    {:ok, formatted} = datetime |> DateFormat.format("%Y-%m-%d %H:%I", :strftime)

    job |> Map.put(:formattedPublished, formatted)

  end

  defp get_updated_datetime(job, key) do
    job
    |> Map.get(key)
    |> DateFormat.parse("{ISOz}")
  end

  def sanitize_job_data(job) do
    job
    |> Map.put(:image, job |> Map.get(:description))
  end

  defp replace_culprits(job) do
    culprits = Map.get(job, :culprits) |> Enum.map(&(Map.get(&1, "fullName")))
    job |> Map.put(:culprits, culprits)
   end

  defp convert_to_job_struct(map) do struct(UvdFooter.Job, map) end

  def add_in_extra_job_data(job, link) do

    %{ body: json_string } = HTTPotion.get Map.get(job, link)

    Parser.parse!(json_string)
    |> string_keys_to_atoms
    |> Map.merge(job)
  end

  defp string_keys_to_atoms(string_key_map) do
      for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}
  end

  def replace_api_job_link(job) do
    job |> Map.put(:job_link, api_link(job |> Map.get(:id)))
  end

  def replace_api_build_link(job) do
    job |> Map.put(:build_link, api_link(job |> Map.get(:link)))
  end

  defp api_link(link) do
    link
    |> replace_prefix("tag:hudson.dev.java.net,2008:", "")
    |> replace_prefix("http://", "http://#{auth_string}@")
    |> replace_suffix("/", "/api/json")
  end

  def from_string(xml_string, options \\ [quiet: true]) do
    {doc, []} =
      xml_string
      |> :binary.bin_to_list
      |> :xmerl_scan.string(options)
    doc
  end

 def attr(node, name), do: node |> xpath('./@#{name}') |> extract_attr
 defp extract_attr([xmlAttribute(value: value)]), do: List.to_string(value)
 defp extract_attr(_), do: nil
 defp xpath(nil, _), do: []
 defp xpath(node, path) do
    :xmerl_xpath.string(to_char_list(path), node)
 end

 def parse(node) do

   cond do
     Record.is_record(node, :xmlElement) ->

     name = xmlElement(node, :name)

     content = if "link" == name |> to_string do
       attr(node, "href")
     else
       parse(xmlElement(node, :content))
     end

     Map.put(%{}, name, content)

     Record.is_record(node, :xmlText) ->
       xmlText(node, :value) |> to_string

     is_list(node) ->
       case Enum.map(node, &(parse(&1))) do
         [text_content] when is_binary(text_content) ->
          text_content

         elements ->
           Enum.reduce(elements, %{}, fn(x, acc) ->
             if is_map(x) do
               Map.merge(acc, x)
             else
               acc
             end
           end)
         end

      true -> "Not supported to parse #{inspect node}"

    end
  end

end