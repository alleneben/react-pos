import React, { useState, useContext, useEffect } from "react";

import * as s from "../../shardslib";
import * as c from '../../components'

import { AppContext } from '../../appstate/appcontext'
import utils from '../../appstate/utils';
import * as cf from '../forms'

let cboc;
let cbou;
let cnts;

const Security = (props) => {
  
  const { state, dispatch } = useContext(AppContext)


  // menus and content
  const submenus = (menus) => {
    if (menus.text === 'Create') {
      switch (menus.cid) {
        case 'asset':
          console.log(menus.cid);
          break;
        case 'productcategories':
          console.log(menus.cid);
          break;
        default:
          console.log('pass');
      }
    } else {
      switch (menus.cid) {
        case 'role':
          console.log(menus.cid);
          break;
        default:
          console.log('default');
          break;
      }
    }
  }
  const makesubmenus = () => {
    if (!!!state.auhmn.text) return;
    return <> {state.auhmn.smenus.map((mn,key) => <a key={key} className="menu-btn animated slideInLeft"  target="_blank" rel="noopener noreferrer" onClick={() => submenus(mn)}>{mn.text}</a>)} </>
  }

  return (
    <s.Container fluid className="main-content-container px-4 pb-4 pt-4">
      <s.Row>
      <div className="menu-container">{ makesubmenus() }</div>
        <s.Col lg="12" md="12">
          jjkk
        </s.Col>
      </s.Row>
    </s.Container>
  );
}
export default Security;
