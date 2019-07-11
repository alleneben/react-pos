import React, {useState} from "react";
import { Link } from "react-router-dom";
import * as s from "shards-react";

import api from '../../../appstate/api';

const UserActions = () => {
  var ud = JSON.parse(localStorage.getItem('nam'));
  
  const [visible, setVisible] = useState(false);
  // const [nam, setnam] = useState()
  const toggleUserActions = () => {
    setVisible((prevState) => !prevState)
  }

  const onLogout = () => {
    var fm = new FormData()
    fm.append('s','auth');
    fm.append('a','logout');
    fm.append('m','l');
    fm.append("ssi", document.cookie.split("=")[1]);
    fm.append('uid',46)

    //dispatch({type:'USER_LOGGED_OUT',initloading:true});

    window.localStorage.clear()
    api.fxns.logout(fm,api.fxns.endpoint).then(rd => {
      //dispatch({type:'USER_LOGGED_OUT',initloading:false});
      localStorage.clear()
      //props.history.push('/')
      window.location.reload()
      document.cookie = "_inspire= ; expires = Thu, 01 Jan 1970 00:00:00 GMT"

    },err =>{
    //  dispatch({type:'USER_LOGGED_OUT',initloading:false});
      localStorage.clear()
      window.location.reload()
      document.cookie = "_inspire= ; expires = Thu, 01 Jan 1970 00:00:00 GMT"
    })
  }

  return (
    <s.NavItem tag={s.Dropdown} caret toggle={toggleUserActions}>
      <s.DropdownToggle caret tag={s.NavLink} className="text-nowrap px-3">
        <img
          className="user-avatar rounded-circle mr-2"
          src={require("./../../../assets/img/0.jpeg")}
          alt="User Avatar"
        />{" "}
        <span className="d-none d-md-inline-block logout"></span>
      </s.DropdownToggle>
      <s.Collapse tag={s.DropdownMenu} right small open={visible}>
        {/*<s.DropdownItem tag={Link} to="user-profile">
          <i className="material-icons">&#xE7FD;</i> Profile
        </s.DropdownItem>
        <s.DropdownItem tag={Link} to="edit-user-profile">
          <i className="material-icons">&#xE8B8;</i> Edit Profile
        </s.DropdownItem>
        <s.DropdownItem tag={Link} to="file-manager-list">
          <i className="material-icons">&#xE2C7;</i> Files
        </s.DropdownItem>
        <s.DropdownItem tag={Link} to="transaction-history">
          <i className="material-icons">&#xE896;</i> Transactions
        </s.DropdownItem>*/}
        <s.DropdownItem divider />
        <s.DropdownItem  className="text-danger logout" onClick={onLogout}>
          <i className="material-icons text-danger">&#xE879;</i> Logout
        </s.DropdownItem>
      </s.Collapse>
    </s.NavItem>
  );
}

export default UserActions;
