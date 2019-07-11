import React from 'react'
import classNames from "classnames";
import {FormGroup,Col, DatePicker,InputGroupAddon,InputGroupText} from "shards-react";

import "../../assets/css/range-date-picker.css";

const DateField = ({align,md,label,id,placeholder,type,name,value,onChange,readOnly}) => {

  return(
    <React.Fragment>
      <Col className={align} md={md}>
        <FormGroup>
        <label htmlFor={id}>{label}</label><br/>
          <DatePicker
            selected={value}
            onChange={onChange}
            placeholderText={placeholder}
            dropdownMode="select"
            className="text-center"
          />
        </FormGroup>
      </Col>
    </React.Fragment>
  );
}


export default DateField;
