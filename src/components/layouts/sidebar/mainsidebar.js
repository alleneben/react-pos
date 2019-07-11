import React,{useState, useEffect, useContext} from "react";
import PropTypes from "prop-types";
import classNames from "classnames";
import * as s from "shards-react";

import SidebarMainNavbar from "./sidebarmainnav";
import NavbarSearch from '../navbar/navbarsearch';
import SidebarNavItems from "./sidebarnavitems";

import { Store } from "../../../flux";

import api from '../../../appstate/api';
import {AppContext} from '../../../appstate/appcontext';

const useRequest = (onChange) => {
  useEffect(() => {
    Store.addChangeListener(onChange);

    return function cleanup() {
      Store.removeChangeListener(onChange);
    }
  })

  return true;
}

const MainSidebar = (props) => {
  const [menuVisible, setMenuVisible] = useState(false);
  const [sidebarNavItems, setSidebarNavItems] = useState(Store.getSidebarItems())
  const [menuItems,setItems] = useState(JSON.parse(localStorage.getItem('data')))


  const onChange = () => {
    setMenuVisible(Store.getMenuState());
    setSidebarNavItems(Store.getSidebarItems());
  }


  const classes = classNames(
    "main-sidebar",
    "px-0",
    "col-12",
    menuVisible && "open"
  );

  useRequest(onChange);

  return (
    <s.Col
      tag="aside"
      className={classes}
      lg={{ size: 2 }}
      md={{ size: 3 }}
    >
    <SidebarMainNavbar hideLogoText={props.hideLogoText} />
    <NavbarSearch />
    <SidebarNavItems menuItems={menuItems}/>

    </s.Col>
  );
}

MainSidebar.propTypes = {
  /**
   * Whether to hide the logo text, or not.
   */
  hideLogoText: PropTypes.bool
};

MainSidebar.defaultProps = {
  hideLogoText: false
};

export default MainSidebar;
