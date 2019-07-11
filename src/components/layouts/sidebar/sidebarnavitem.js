import React, {useContext} from "react";
import PropTypes from "prop-types";
import { NavLink as RouteNavLink } from "react-router-dom";

import * as s from "shards-react";
import {AppContext} from '../../../appstate/appcontext'

const SidebarNavItem = ({ item }) => {
  const { state, dispatch,props } = useContext(AppContext)
  var itemTo = "/"+(item.text.replace(/ /g,'')).toLowerCase();

const dispatchsubmenu = () => dispatch({type:'SUB_MENUS',payload:item,initloading:false})

  return (
    <s.NavItem style={{ height: '40px'}}>
      <s.NavLink tag={RouteNavLink} to={itemTo} onClick={dispatchsubmenu}>
        {item.htmlBefore && (
          <div
            className="d-inline-block item-icon-wrapper"
            dangerouslySetInnerHTML={{ __html: item.htmlBefore }}
          />
        )}
        {item.text && <span>{item.text}</span>}
        {item.htmlAfter && (
          <div
            className="d-inline-block item-icon-wrapper"
            dangerouslySetInnerHTML={{ __html: item.htmlAfter }}
          />
        )}
      </s.NavLink>
    </s.NavItem>
  )
}

SidebarNavItem.propTypes = {
  /**
   * The item object.
   */
  item: PropTypes.object
};

export default SidebarNavItem;
