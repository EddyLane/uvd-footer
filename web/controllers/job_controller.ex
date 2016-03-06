defmodule UvdFooter.JobController do

  use UvdFooter.Web, :controller

  import String, only: [replace_prefix: 3, replace_suffix: 3]

  alias Timex.DateFormat
  alias Timex.Date
  alias Poison.Parser

  require Record

  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")

  def index(conn, _params) do

    IO.puts auth_string
    IO.puts ci_url

    %{ body: xml_string } = HTTPotion.get("http://#{auth_string}@#{ci_url}/rssLatest")

    jobs = xml_string
       |> from_string
       |> xpath("//entry")
       |> Enum.map(&xmlElement(&1, :content) |> parse)
       |> Enum.sort(&sort_dates/2)
       |> Enum.take(3)
       |> Enum.map(&replace_api_link/1)
       |> Enum.map(&add_in_extra_job_data/1)
       |> Enum.map(&sanitize_job_data/1)

    json(conn, jobs)

  end


  def auth_string do "#{ci_user}:#{ci_token}" end

  def ci_url do Application.get_env(:uvd_footer, :ci_url) end
  def ci_token do Application.get_env(:uvd_footer, :ci_token) end
  def ci_user do Application.get_env(:uvd_footer, :ci_user) end

  def sort_dates(first, second) do

    {:ok, first_date} =  get_updated_datetime(first)
    {:ok, second_date} = get_updated_datetime(second)

    Date.compare(first_date, second_date) == 1
  end

  defp get_updated_datetime(job) do
    job
    |> Map.get(:updated)
    |> DateFormat.parse("{ISOz}")
  end

  def sanitize_job_data(job) do
    job |> Map.take([:updated, :title, :timestamp, :result, :published, :number, :fullDisplayName, :estimatedDuration, :duration, :displayName])
  end

  def add_in_extra_job_data(job) do


    IO.puts Map.get(job, :link)

    %{ body: json_string } = HTTPotion.get Map.get(job, :link)
    Parser.parse!(json_string)
    |> string_keys_to_atoms
    |> Map.merge(job)
  end

  defp string_keys_to_atoms(string_key_map) do
      for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}
  end

  def replace_api_link(job) do
    link = job |> Map.get(:link)
    job |> Map.put(:link, link |> api_link)
  end

  defp api_link(link) do
    link
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
