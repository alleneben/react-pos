import React, {useContext} from "react";
import { Route, Switch } from "react-router-dom";
import * as s from "shards-react";
import * as c from '../components'

import HomeRoutes from '../HomeRoutes';
import {AppContext} from '../appstate/appcontext'


const Home = () => {

  const { state, dispatch,props } = useContext(AppContext)
  let loggedin = !!localStorage.getItem('token');

  if(state.menu.length === 0){

  } else {
    localStorage.setItem('data', JSON.stringify(state))
  }

  const init = () => 'hello, you have to login first';
  
  const homepage = () => <s.Row>
      <c.MainSidebar />
      <s.Col
        className="main-content p-0"
        lg={{ size: 10, offset: 2 }}
        md={{ size: 9, offset: 3 }}
        sm="12"
        tag="main"
      >
      <c.MainNavbar />
      <HomeRoutes />
      <c.Footer />
      </s.Col>
    </s.Row>

  return (
      loggedin ? homepage() : init()
  );

};
export default Home;
