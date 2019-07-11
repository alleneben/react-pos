import React, {useEffect, useState,useReducer} from "react";

import appReducer from '../appstate/reducers';
import { AppContext } from '../appstate/appcontext';
import api from '../appstate/api';
import utils from '../appstate/utils'
import CRoutes from '../CRoutes';

import * as s from "../shardslib";


const DefaultLayout = (props) => {
  const [state, dispatch] = useReducer(appReducer,{menu:[],auhmn:[]})

  const rd = utils.utilfxns.applicationstart(dispatch)
  const { value,msg } = rd;

  window.addEventListener('DOMContentLoaded', function(){

    if(!!localStorage.getItem('token')){
        props.history.push('/Dashboard');
    } else {
        props.history.push('/')
        console.log('rd');
    }
  })

  return (
    <AppContext.Provider value={{state,props,dispatch}}>
      <s.Container fluid className="shards-landing-page--1">
        { value ? <CRoutes /> : <s.Spinner />}
        {/*<s.Row>
          <MainSidebar />
          <s.Col
            className="main-content p-0"
            lg={{ size: 10, offset: 2 }}
            md={{ size: 9, offset: 3 }}
            sm="12"
            tag="main"
          >
          <MainNavbar />
          {children}
          <Footer />
          </s.Col>
        </s.Row>*/}
      </s.Container>
    </AppContext.Provider>
  );
}



export default DefaultLayout;
