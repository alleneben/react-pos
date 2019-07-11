import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter, Route } from 'react-router-dom';

import * as serviceWorker from './serviceWorker';

// import routes from './routes';
import "./assets/css/icon.css";
import "bootstrap/dist/css/bootstrap.min.css";
import "./assets/css/shards-dashboards.1.1.0.min.css";
import './index.css';
import "./assets/css/animate.css";
import "./assets/css/shards-extras.min.css?version=2.1.2"

import { DefaultLayout } from './layout/'


ReactDOM.render(
  <BrowserRouter>
      <Route component={DefaultLayout}/>
  </BrowserRouter>, document.getElementById('root'));

serviceWorker.register();
