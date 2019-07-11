import React, { useState, useEffect } from "react";
import * as s from "shards-react";


import SidebarNavItem from "./sidebarnavitem";
import { Store } from "../../../flux";


const dashboardItem = { text: "Dashboard", to: "/home", htmlBefore: '<i class="material-icons">edit</i>', htmlAfter: ""}

const useRequest = (onChange) => {
  useEffect(() => {
    Store.addChangeListener(onChange);

    return function cleanup() {
      Store.removeChangeListener(onChange);
    }
  })

  return true;
}




const SidebarNavItems = ({ menuItems }) => {
  const [navItems, setSidebarNavItems] = useState(Store.getSidebarItems());

  const onChange = () => {
    setSidebarNavItems(Store.getSidebarItems())
  }

  useRequest(onChange);

  let items  = menuItems.menu;
  return (
    <div className="nav-wrapper">
      <s.Nav className="nav--no-borders flex-column">
        <SidebarNavItem item={dashboardItem} />
        {items.map((item, idx) => (
          <SidebarNavItem key={idx} item={item} />
        ))}
      </s.Nav>
    </div>
  )
}

export default SidebarNavItems;
