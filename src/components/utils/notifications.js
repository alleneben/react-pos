import React, { useState } from "react";

import * as s from "../../shardslib";

/**
 * ## Dismissible Alerts
 *
 * Dismissible alerts allow you to hide them using an `X` button.
 */
const Notification = ({ theme, msg, visible, dismissfn }) => {


  const dismiss = () => {
    dismissfn(false)
  }

  return (
    <s.Alert className="notify" theme={theme} dismissible={dismiss} open={visible}>
      {msg} &rarr;
    </s.Alert>
  );

}

export default Notification;
