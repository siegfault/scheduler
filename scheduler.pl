valid_times_between(Begin, End, ValidTimes) :-
  QuarterHours = [
    0000, 0015, 0030, 0045,
    0100, 0115, 0130, 0145,
    0200, 0215, 0230, 0245,
    0300, 0315, 0330, 0345,
    0400, 0415, 0430, 0445,
    0500, 0515, 0530, 0545,
    0600, 0615, 0630, 0645,
    0700, 0715, 0730, 0745,
    0800, 0815, 0830, 0845,
    0900, 0915, 0930, 0945,
    1000, 1015, 1030, 1045,
    1100, 1115, 1130, 1145,
    1200, 1215, 1230, 1245,
    1300, 1315, 1330, 1345,
    1400, 1415, 1430, 1445,
    1500, 1515, 1530, 1545,
    1600, 1615, 1630, 1645,
    1700, 1715, 1730, 1745,
    1800, 1815, 1830, 1845,
    1900, 1915, 1930, 1945,
    2000, 2015, 2030, 2045,
    2100, 2115, 2130, 2145,
    2200, 2215, 2230, 2245,
    2300, 2315, 2330, 2345
  ],
  findall(Time, (between(Begin, End, Time), member(Time, QuarterHours)), ValidTimes).

fully_available(AvailableHours, ShiftBegin, ShiftEnd) :-
  valid_times_between(ShiftBegin, ShiftEnd, NecessaryHours),
  forall(member(NecessaryHour, NecessaryHours), member(NecessaryHour, AvailableHours)).

can_work(Shift, Person) :-
  [_|[ShiftBegin|[ShiftEnd|_]]] = Shift,
  [_|AvailableHours] = Person,
  fully_available(AvailableHours, ShiftBegin, ShiftEnd).

number_of_people_that_can_work(Shift, People, Count) :-
  findall(Person, (member(Person, People), can_work(Shift, Person)), AvailableWorkers),
  length(AvailableWorkers, Count).

more_contested(Shift1, Shift2, People, Shift) :-
  number_of_people_that_can_work(Shift1, People, Shift1Count),
  number_of_people_that_can_work(Shift2, People, Shift2Count),
  (Shift1Count =< Shift2Count
    -> Shift = Shift1
    ; Shift = Shift2
  ).

most_contested_shift([FirstShift|OtherShifts], People, MostContestedShift) :-
  most_contested_shift(OtherShifts, FirstShift, People, MostContestedShift).
most_contested_shift([], Shift, _, Shift).
most_contested_shift([FirstShift|OtherShifts], CandidateShift, People, MostContestedShift) :-
  more_contested(FirstShift, CandidateShift, People, MoreContestedShift),
  most_contested_shift(OtherShifts, MoreContestedShift, People, MostContestedShift).

next_shift_to_schedule(Shifts, People, Shift) :- most_contested_shift(Shifts, People, Shift).
next_employee_to_schedule(Shift, People, Person) :-
  member(Person, People),
  can_work(Shift, Person).
assign(Person, Shift, People, Shifts, PeopleLeft, ShiftsLeft) :-
  select(Shift, Shifts, ShiftsLeft),
  select(Person, People, PeopleLeft).

schedule([], _, []).
schedule(_, [], []).
schedule(Shifts, People, Schedule) :-
  next_shift_to_schedule(Shifts, People, ShiftToSchedule),
  next_employee_to_schedule(ShiftToSchedule, People, PersonToSchedule),
  assign(PersonToSchedule, ShiftToSchedule, People, Shifts, PeopleLeft, ShiftsLeft),
  schedule(ShiftsLeft, PeopleLeft, PartialSchedule),
  [ShiftName|_] = ShiftToSchedule,
  [PersonName|_] = PersonToSchedule,
  append(PartialSchedule, [ShiftName, PersonName], Schedule).

person_to_list(Name, List) :-
  person(Name, Begin, End),
  valid_times_between(Begin, End, WorkingHours),
  List = [Name|WorkingHours].

shift_to_list(Name, List) :-
  shift(Name, Begin, End),
  List = [Name|[Begin,End]].

person(michael, 215, 330).
person(sue, 130, 300).
shift(blue_plate, 230, 330).
shift(order_up, 130, 230).

test_schedule(Schedule) :-
  person_to_list(michael, Michael),
  person_to_list(sue, Sue),
  shift_to_list(blue_plate, BluePlate),
  shift_to_list(order_up, OrderUp),

  schedule([BluePlate, OrderUp], [Sue, Michael], Schedule).
