import React from "react";
import PropTypes from "prop-types";
import classNames from "classnames";


import * as s from "shards-react";
import NavbarSearch from './navbarsearch';
import NavbarNav from './navbarnav';
import NavbarToggle from './navbartoggle';

const MainNavbar = ({ layout, stickyTop }) => {
  const classes = classNames(
    "main-navbar",
    "bg-white",
    stickyTop && "sticky-top"
  );

  return (
    <div className={classes}>
      <s.Container className="p-0">
        <s.Navbar type="light" className="align-items-stretch flex-md-nowrap p-0">
        <NavbarSearch />
        <NavbarNav />
        <NavbarToggle />

        </s.Navbar>
      </s.Container>
    </div>
  );
};

MainNavbar.propTypes = {
  /**
   * The layout type where the MainNavbar is used.
   */
  layout: PropTypes.string,
  /**
   * Whether the main navbar is sticky to the top, or not.
   */
  stickyTop: PropTypes.bool
};

MainNavbar.defaultProps = {
  stickyTop: true
};

export default MainNavbar;
