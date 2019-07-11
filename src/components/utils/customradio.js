import React from "react";
import { FormRadio,Col } from "shards-react";



const CustomRadio = ({ label, name,md,align,checked, onChange }) =>  {

  return (
    <React.Fragment>
    <Col className={align} md={md}>
      <p className="mb-2"></p>
      <FormRadio
        inline
        name={name}
        checked={checked}
        onChange={onChange}
      >
        { label }
      </FormRadio>
    </Col>
    </React.Fragment>
  );
}

export default CustomRadio;
