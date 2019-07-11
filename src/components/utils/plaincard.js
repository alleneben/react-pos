import React from "react";
import * as s from "shards-react";


// const didMount = (canvasRef,props) => {
//   useEffect(() => {
//
//     return function cleanup() {
//
//     }
//   })
//
//   return true;
// }


const PlainCard = (props) => {

  const { children, animated } = props;

  return (
    <s.Card small className={animated}>
      <s.CardBody className="pb-0">
        { children }
      </s.CardBody>
    </s.Card>
  );
}

export default PlainCard;
