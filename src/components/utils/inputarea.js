import React from 'react'
import {FormGroup, FormTextarea,Col,} from "shards-react";


function InputArea({align,md,row,label,id,placeholder,type,name,value,onChange,readOnly,required,invalid}) {
  return(
    <React.Fragment>
      <Col className={align} md={md}>
        <FormGroup>
          <label htmlFor={id}>{label}</label>
          <FormTextarea
            rows={row}
            id={id}
            placeholder={placeholder}
            type={type}
            name={name}
            value={value}
            onChange={onChange}
            readOnly={readOnly}
            required = {required}
            invalid={invalid}
          />
        </FormGroup>
      </Col>
    </React.Fragment>
  );
}


export default InputArea;
