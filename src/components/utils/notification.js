import React, { useEffect } from 'react';
import NotificationAlert from "react-notification-alert";


let isMounted;
const Notification = ({ place, type, msg, time}) =>{
  let notificationAlertRef = React.createRef()

  useEffect(()=>{
    isMounted = true;
    var options = {};
    options = {
      place: place,
      message: (
        <div>
          <div>
            { msg }
          </div>
        </div>
      ),
      type: type,
      icon: "tim-icons icon-bell-55",
      autoDismiss: time
    };

    if (isMounted) {
      notificationAlertRef.current.notificationAlert(options);
    }

    return function cleanup() {
      isMounted = false;
    }
  },[])

  return (
    <>
    <div className="react-notification-alert-container">
      <NotificationAlert ref={notificationAlertRef} />
    </div>
    </>
  );

}


export default Notification;
