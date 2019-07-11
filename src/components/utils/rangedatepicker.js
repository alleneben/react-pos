import React, { useState } from "react";
import classNames from "classnames";
import {
  InputGroup,
  DatePicker,
  InputGroupAddon,
  InputGroupText
} from "shards-react";

import "../../assets/css/range-date-picker.css";

const RangeDatePicker = (props) => {

  const [startDate, setStartDate] = useState(undefined);
  const [endDate, setEndDate] = useState(undefined);


  const handleStartDateChange = (value) => {
    setStartDate(new Date(value))
  }

  const handleEndDateChange = (value) => {
    setEndDate(new Date(value))
  }

  const { className } = props;
  const classes = classNames(className, "d-flex", "my-auto", "date-range");

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
        <InputGroupText>
          <i className="material-icons">&#xE916;</i>
        </InputGroupText>
      </InputGroupAddon>
    </InputGroup>
  );
}

export default RangeDatePicker;
