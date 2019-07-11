import React,{ useState } from "react";
import * as s from "shards-react";

const Notifications = () => {

  const [visible, setVisible] = useState(false)


  const toggleNotifications = () => {
    setVisible((prevState) => !prevState);
  }

  return (
    <s.NavItem className="border-right dropdown notifications">
      <s.NavLink
        className="nav-link-icon text-center"
        onClick={toggleNotifications}
      >
        <div className="nav-link-icon__wrapper logout">
          <i className="material-icons">&#xE7F4;</i>
          <s.Badge pill theme="danger">
            2
          </s.Badge>
        </div>
      </s.NavLink>
      <s.Collapse
        open={visible}
        className="dropdown-menu dropdown-menu-small"
      >
        <s.DropdownItem>
          <div className="notification__icon-wrapper">
            <div className="notification__icon">
              <i className="material-icons">&#xE6E1;</i>
            </div>
          </div>
          <div className="notification__content">
            <span className="notification__category">Analytics</span>
            <p>
              Your website’s active users count increased by{" "}
              <span className="text-success text-semibold">28%</span> in the
              last week. Great job!
            </p>
          </div>
        </s.DropdownItem>
        <s.DropdownItem>
          <div className="notification__icon-wrapper">
            <div className="notification__icon">
              <i className="material-icons">&#xE8D1;</i>
            </div>
          </div>
          <div className="notification__content">
            <span className="notification__category">Sales</span>
            <p>
              Last week your store’s sales count decreased by{" "}
              <span className="text-danger text-semibold">5.52%</span>. It
              could have been worse!
            </p>
          </div>
        </s.DropdownItem>
        <s.DropdownItem className="notification__all text-center">
          View all Notifications
        </s.DropdownItem>
      </s.Collapse>
    </s.NavItem>
  );
}

export default Notifications;
