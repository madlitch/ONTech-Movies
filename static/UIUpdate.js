// initializes the variables needed for the input validation
// it is easier to access the DOM information in javascript, which is why we employed it here in conjunction with python
let count = 0;
let seats = [];
let checked = false;
let num;
let char;
let button;

// creates a list of all possible seats in a movie theatre
for (num = 1; num <= 10; num++) {
    for (char of "ABCDEFGHIJ") {
        seats.push("" + char + num);
    }
}

// creates an array of seats that are currently booked by their respective screening
function createSeatArray(seat_list) {
    let new_array = [];
    seat_list = seat_list.replace("[","").replace("]","").split(", ");
    for (let element of seat_list)
        new_array.push(element.split("_"));
    return new_array;
}

// whenever a different screening is selected, it resets all seats and respective checkboxes to unchecked, then goes
// through the list of booked seats and disables them and changes their class (so their colour is different)
function updateBookedSeats(booked, screening) {
    count = 0;
    for (num = 1; num <= 10; num++) {
        for (char of "ABCDEFGHIJ") {
            document.getElementById(char + num + "b").className = "seat zoom btn btn-outline-primary";
            document.getElementById("" + char + num).checked = false;
            document.getElementById(char + num + "b").disabled = false;
        }
    }
    for (let element of booked) {
        if (element[1] === screening.id.replace("screening_", "")) {
            document.getElementById(element[0] + "b").disabled = true;
            document.getElementById(element[0] + "b").className = "seat btn btn-danger";
            document.getElementById(element[0]).checked = false;
        }
    }
}

// asserts that all fields are filled before the book button is enabled
function assertFilled() {
    let student_id = document.getElementById("student_id").value;
    let first_name = document.getElementById("first_name").value;
    let last_name = document.getElementById("last_name").value;
    document.getElementById("bookNow").disabled = !(student_id !== "" && first_name !== ""
        && last_name !== "" && count > 0 && checked);
}

// the toggleScreening and toggleSeat functions essentially emulate checkbox behaviour in the buttons that we put in
// their place, and checks the button's respective checkbox or radio so that that information is passed through the form
function toggleScreening(element) {
    checked = true;
    document.getElementById("" + element.id + "r").checked = true;
    let radio_buttons = document.getElementsByName("screening_buttons");
    for (button of radio_buttons){
        button.className = "zoom btn btn-outline-primary";
    }
    element.className = "zoom btn btn-success";
    assertFilled();
}

function toggleSeat(element) {
    if (element.className === "seat zoom btn btn-outline-primary"){
        element.className = "seat zoom btn btn-success";
        document.getElementById("" + element.value).checked = true;
        seats.splice(seats.indexOf(element.value), 1);
        count++;
    } else {
        element.className = "seat zoom btn btn-outline-primary";
        document.getElementById("" + element.value).checked = false;
        seats.push(element.value);
        count--;
    }
    // disables all seats if 5 seats are selected, if one is unselected then they all become available again
    if (count === 5) {
        document.getElementsByClassName("seat zoom btn btn-outline-primary").disabled = true;
        for (element of seats) {
            if(document.getElementById("" + element + "b").className !== "seat btn btn-danger") {
                document.getElementById("" + element + "b").disabled = true;
            }
        }
    } else {
        document.getElementsByClassName("zoom btn btn-outline-primary").disabled = false;
        for (element of seats) {
            if(document.getElementById("" + element + "b").className !== "seat btn btn-danger") {
                document.getElementById("" + element + "b").disabled = false;
            }
        }
    }
    assertFilled();
}



