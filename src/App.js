import React from 'react';
import { BrowserRouter as Router, Route } from "react-router-dom";

import routes from "./zroutes";
// import "./assets/css/icon.css";
// import "bootstrap/dist/css/bootstrap.min.css";
// import "./assets/css/shards-dashboards.1.1.0.min.css";

export default () => (
  <Router>
    <div>
      {
        routes.map((route, index) => {
          return (
            <Route key={index} exact={route.exact} path={route.path}  component={ props => { return (<route.layout {...props}><route.component {...props}/></route.layout>)}}/>
          )
        })
      }
    </div>
  </Router>
);
