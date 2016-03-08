import '../styles/main.scss'

import {Socket} from './vendor/phoenix'
import Elm from '../../elm/Main'

const app = Elm.embed(Elm.Main, document.getElementById('root'), { jobs: [] });
const socket = new Socket("/socket", {params: {token: window.userToken}});
const channel = socket.channel("rooms:lobby", {});

channel.on("list", ({ list }) => app.ports.jobs.send(list));

socket.connect();

channel.join()
    .receive("ok", resp => console.log("Joined successfully", resp))
    .receive("error", resp => console.log("Unable to join", resp));