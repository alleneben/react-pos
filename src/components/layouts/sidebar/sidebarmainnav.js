import React from "react";
import PropTypes from "prop-types";
import * as s from "shards-react";


import { Dispatcher, Constants } from "../../../flux";

const SidebarMainNavbar = (props) => {


  const handleToggleSidebar = () => {
    Dispatcher.dispatch({
      actionType: Constants.TOGGLE_SIDEBAR
    });
  }

  const { hideLogoText } = props;
  return (
    <div className="main-navbar">
      <s.Navbar
        className="align-items-stretch bg-white flex-md-nowrap border-bottom p-0"
        type="light"
      >
        <s.NavbarBrand
          className="w-100 mr-0"
          href="#"
          style={{ lineHeight: "25px" }}
        >
          <div className="d-table m-auto">
            <img
              id="main-logo"
              className="d-inline-block align-top mr-1"
              style={{ maxWidth: "25px" }}
              src={require("../../../assets/img/shards-dashboards-logo.svg")}
              alt="Shards Dashboard"
            />
            {!hideLogoText && (
              <span className="d-none d-md-inline ml-1">
                TeckMines
              </span>
            )}
          </div>
        </s.NavbarBrand>
        {/* eslint-disable-next-line */}
        <a
          className="toggle-sidebar d-sm-inline d-md-none d-lg-none"
          onClick={handleToggleSidebar}
        >
          <i className="material-icons">&#xE5C4;</i>
        </a>
      </s.Navbar>
    </div>
  );
}

SidebarMainNavbar.propTypes = {
  /**
   * Whether to hide the logo text, or not.
   */
  hideLogoText: PropTypes.bool
};

SidebarMainNavbar.defaultProps = {
  hideLogoText: false
};

export default SidebarMainNavbar;
