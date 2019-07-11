import React from "react";
import PropTypes from "prop-types";
import { Container, Row, Nav, NavItem, NavLink } from "shards-react";
import { Link } from "react-router-dom";

const Footer = ({ contained, menuItems, copyright }) => (
  <footer className="main-footer d-flex p-2 px-3 bg-white border-top">
    <Container fluid={contained}>
      <Row>
        <Nav>
          {menuItems.map((item, idx) => (
            <NavItem key={idx}>
              <NavLink tag={Link} to={item.to}>
                {item.title}
              </NavLink>
            </NavItem>
          ))}
        </Nav>
        <span className="copyright ml-auto my-auto mr-2">{copyright}</span>
      </Row>
    </Container>
  </footer>
);

Footer.propTypes = {
  /**
   * Whether the content is contained, or not.
   */
  contained: PropTypes.bool,
  /**
   * The menu items array.
   */
  menuItems: PropTypes.array,
  /**
   * The copyright info.
   */
  copyright: PropTypes.string
};

Footer.defaultProps = {
  contained: false,
  copyright: "Copyright © 2019 Allen Eben",
  menuItems: [
    // {
    //   title: "Home",
    //   to: "Dashboard"
    // },
    // {
    //   title: "Manage",
    //   to: "Manage"
    // },
    // {
    //   title: "Report",
    //   to: "Reports"
    // },
    // {
    //   title: "Settings",
    //   to: "Setting"
    // },
  ]
};

export default Footer;
