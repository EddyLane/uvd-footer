import './vendor/phoenix_html'
import * as Phoenix from './vendor/phoenix'
import Elm from '../../elm/Main'

import '../styles/main.scss'

const app = Elm.embed(Elm.Main, document.getElementById('root'));
