import React from "react";
import * as s from "shards-react";

import Notifications from "./notifications";
import UserActions from "./useractions";

export default () => (
  <s.Nav navbar className="border-left flex-row">
    <Notifications />
    <UserActions />
  </s.Nav>
);
