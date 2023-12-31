
CREATE TABLE IF NOT EXISTS students (
	code VARCHAR ( 13 ) PRIMARY KEY UNIQUE NOT NULL,
	stName VARCHAR ( 100 ) NOT NULL,
  	stLastName VARCHAR ( 100 ) NOt NULL,
  	email VARCHAR ( 100 ) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS classrooms (
	code VARCHAR ( 8 ) PRIMARY KEY UNIQUE NOT NULL,
	chairs INT NOT NULL
);

CREATE TABLE IF NOT EXISTS bookings (
	code VARCHAR ( 8 ) NOT NULL,
	booking_date TIMESTAMP NOT NULL,
  	duration INT NOT NULL,
  	booked_chairs INT NOT NULL,
  	email VARCHAR ( 100 ) 
);


