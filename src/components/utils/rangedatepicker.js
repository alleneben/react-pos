import React, { useState } from "react";
import classNames from "classnames";
import {
  InputGroup,
  DatePicker,
  InputGroupAddon,
  InputGroupText
} from "shards-react";

import "../../assets/css/range-date-picker.css";

const RangeDatePicker = ({className,onStartChange, onEndChange, clearfilters}) => {

  const [startDate, setStartDate] = useState(undefined);
  const [endDate, setEndDate] = useState(undefined);


  const handleStartDateChange = (value) => {
    onStartChange(new Date(value))
    setStartDate(new Date(value))
  }

  const handleEndDateChange = (value) => {
    onEndChange(new Date(value))
    setEndDate(new Date(value))
  }


  const classes = classNames(className, "d-flex", "my-auto", "date-range");

  const clear = () => {
    setStartDate(undefined)
    setEndDate(undefined)
    clearfilters()
  }
  return (
    <InputGroup className={classes}>
      <DatePicker
        size="sm"
        selected={startDate}
        onChange={handleStartDateChange}
        placeholderText="Start Date"
        dropdownMode="select"
        className="text-center"
      />
      <DatePicker
        size="sm"
        selected={endDate}
        onChange={handleEndDateChange}
        placeholderText="End Date"
        dropdownMode="select"
        className="text-center"
      />
      <InputGroupAddon type="append">
        <InputGroupText onClick={clear} className="clearfilters">
          <i className="material-icons">&#xE916;</i>
          Clear
        </InputGroupText>
      </InputGroupAddon>
    </InputGroup>
  );
}

export default RangeDatePicker;
