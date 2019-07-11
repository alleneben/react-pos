import React from "react";

import * as s from "shards-react";

const NavbarSearch = () => {

  return (
    <s.Form className="main-navbar__search w-100 d-none d-md-flex d-lg-flex">
      <s.InputGroup seamless className="ml-3">
        <s.InputGroupAddon type="prepend">
          <s.InputGroupText>
            <i className="material-icons">search</i>
          </s.InputGroupText>
        </s.InputGroupAddon>
        <s.FormInput
          className="navbar-search"
          placeholder="Search for something ..."
        />
      </s.InputGroup>
    </s.Form>
  )
};

export default NavbarSearch;
