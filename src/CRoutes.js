import React from "react";
import { Route, Switch } from "react-router-dom";

import {Login, Home} from  "./views/";

// import zroutes from './zroutes';


const CRoutes = ({history}) => {
    return (
      <Switch>
      <Route exact path="/" component={Login} />
      <Route exact path="/Dashboard" component={Home} />
      <Route exact path="/products" component={Home} />
      <Route exact path="/categories" component={Home} />
      <Route exact path="/pos" component={Home} />
      <Route exact path="/shops" component={Home} />
      <Route exact path="/shops/:id/products" component={Home} />
      <Route exact path="/customers" component={Home} />
      <Route exact path="/customers/:id" component={Home} />
      <Route exact path="/security" component={Home} />
      <Route exact path="/Report" component={Home} />
      <Route exact path="/Settings" component={Home} />
        {
          /*routes.map((route, index) => {
            return (
              <Route key={index} exact={route.exact} path={route.path}  component={ props => { return (<route.component {...props}/>)}}/>
            )
          })*/
        }
      </Switch>
    );
}

export default CRoutes;
