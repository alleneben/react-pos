import React from "react";
import { Row, Col, Card, CardHeader, CardBody, Button,CardFooter } from "shards-react";

import RangeDatePicker from "./rangedatepicker";



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


const CustomCard = (props) => {

  const { title,subtitle,clsnm,children, footer } = props;
  return (
    <Card small className={ clsnm }>
      <CardHeader className="border-bottom">
        <h6 className="m-0">{title}</h6>
      </CardHeader>
      <CardBody className="pt-0">
        {/*<Row className="border-bottom py-2 bg-light">
          <Col sm="6" className="d-flex mb-2 mb-sm-0">
            <RangeDatePicker />
          </Col>
          <Col>
            <Button
              size="sm"
              className="d-flex btn-white ml-auto mr-auto ml-sm-auto mr-sm-0 mt-3 mt-sm-0"
            >
              {subtitle}
            </Button>
          </Col>
        </Row>*/}

        {children ? children : ''}
      </CardBody>
      <CardFooter>
      { footer }
      </CardFooter>
    </Card>
  );
}

export default CustomCard;
