import React from 'react'
import {FormGroup, Input,Col, FormInput,FormFeedback} from "shards-react";

let input;
function InputField({align,md,label,id,placeholder,type,name,value,onChange,readOnly,required,invalid,formtype,hidden}) {

  input = formtype === 'add' ?
  <FormInput id={id} hidden={hidden} placeholder={placeholder} type={type} name={name} value={value} onChange={onChange} readOnly={readOnly} required = {required} invalid={invalid} />
  :
  <FormInput id={id} hidden={hidden} placeholder={placeholder} type={type} name={name} defaultValue={value} onChange={onChange} readOnly={readOnly} required = {required} invalid={invalid} />

  // if(formtype === 'add'){
  //   input = <FormInput id={id} hidden={hidden} placeholder={placeholder} type={type} name={name} value={value} onChange={onChange} readOnly={readOnly} required = {required} invalid={invalid} />
  // } else {
  //   input = <FormInput id={id} hidden={hidden} placeholder={placeholder} type={type} name={name} defaultValue={value} onChange={onChange} readOnly={readOnly} required = {required} invalid={invalid} />
  // }


  return(
    <React.Fragment>
      <Col className={align} md={md}>
        <FormGroup>
          <label htmlFor={id}>{label}</label>
          { input }
          <FormFeedback>The {placeholder} is required</FormFeedback>
        </FormGroup>
      </Col>
    </React.Fragment>
  );
}


export default InputField;
