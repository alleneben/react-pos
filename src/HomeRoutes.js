import React from "react";
import { Route, Switch } from "react-router-dom";

import { Dashboard } from  "./views/";
import * as c from './views/appspecific'
import * as sc from './views/security'

const HomeRoutes = ({history}) => {
    return (
      <Switch>
        <Route exact path="/Dashboard" component={Dashboard} />
        <Route exact path="/products" component={c.Product} />
        <Route exact path="/categories" component={c.ProductCategory} />
        <Route exact path="/pos" component={c.AddNewSales} />
        <Route exact path="/shops" component={c.Shops} />
        <Route exact path="/shops/:id/products" component={c.Product} />
        <Route exact path="/customers" component={c.Customers} />
        <Route exact path="/customers/:id" component={c.Detail} />
        <Route exact path="/security" component={sc.Security} />
        <Route exact path="/Reports" component={c.Product} />
        <Route exact path="/Setting" component={c.Product} />
        <Route
          render={function () {
            return <h5>Page Not Found. It is under fast development</h5>;
          }}
        />
      </Switch>
    );
}

export default HomeRoutes;
