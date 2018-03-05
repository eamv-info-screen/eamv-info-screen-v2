using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using Entities;
using Utils;
using Repositories;
using System.Globalization;
using System.Data.SqlClient;
using System.Linq;

public partial class EditEvent : Page {

    private DataAccess dataAccess = new DataAccess(DataAccess.GetWebConfigConnectionString("Infoskærm"));
    private EventsRepository eventRepository = new EventsRepository();
    public EventEntity eventEntity;
    private WeekNumber weekNumber = new WeekNumber();

    protected void Page_Load(object sender, EventArgs e) {
        if(!IsPostBack) {
            int? eventId = null;
            try {
                eventId = int.Parse(Request.QueryString.Get("eventId"));
            } catch(Exception exc) {
                Response.Redirect("Search.aspx");
            }

            DataAccess dataAccess = new DataAccess(DataAccess.GetWebConfigConnectionString("Infoskærm"));
            try {
                dataAccess.Open();
                EventsRepository eventRepository = new EventsRepository();

                eventEntity = eventRepository.FetchById(dataAccess, (int)eventId);

                startDate.SelectedDate = eventEntity.FromDate.Date;
                startDate.VisibleDate = startDate.SelectedDate;

                endDate.VisibleDate = startDate.SelectedDate;

                MultipleDatesCalender.VisibleDate = startDate.SelectedDate;

                if(eventEntity.IsCanceled == true) {
                    canceled.Visible = true;
                } else {
                    canceled.Visible = false;
                }

                PopulateDepartmentsSelect(dataAccess, eventRepository);

                int departmentId = int.Parse(departmentsSelect.Items[departmentsSelect.SelectedIndex].Value);
                PopulateRoomsSelect(dataAccess, eventRepository, departmentId);
                SelectRooms(eventEntity.Rooms);
            } catch(Exception) {

            } finally {
                dataAccess.Close();
            }
        } else {
            eventEntity = CreateEventEntityFromForm();

            List<int> rooms = GetSelectedRooms();

            dataAccess.Open();
            PopulateRoomsSelect(dataAccess, eventRepository, int.Parse(departmentsSelect.Items[departmentsSelect.SelectedIndex].Value));
            dataAccess.Close();

            SelectRooms(rooms);
        }

        DataBind();
    }

    protected void BeforeNowValidator(object sender, ServerValidateEventArgs e) {
        DateTime startTimeInput = DateTime.ParseExact(startTime.Value, "HH:mm", CultureInfo.InvariantCulture);
        DateTime startDateInput = new DateTime(startDate.SelectedDate.Year, startDate.SelectedDate.Month, startDate.SelectedDate.Day, startTimeInput.Hour, startTimeInput.Minute, startTimeInput.Second);

        if(startDateInput < DateTime.Now) {
            e.IsValid = false;
        } else {
            e.IsValid = true;
        }
    }

    protected void OnFormSubmit(object sender, EventArgs e) {
        if(IsValid) {
            if(!showMultiple.Checked) {
                EventEntity eventEntity = CreateEventEntityFromForm();
                UpdateEvent(eventEntity);
            } else {
                DeleteEvent(eventEntity.Id);
            }

            if(EventShouldRepeats()) {
                try {
                    dataAccess.Open();
                    EventEntity repeatedEventEntity = new EventEntity();

                    DateTime startTimeInput = DateTime.ParseExact(startTime.Value, "HH:mm", CultureInfo.InvariantCulture);
                    DateTime startDateInput = new DateTime(startDate.SelectedDate.Year, startDate.SelectedDate.Month, startDate.SelectedDate.Day,
                        startTimeInput.Hour, startTimeInput.Minute, startTimeInput.Second);
                    repeatedEventEntity.FromDate = startDateInput;

                    DateTime endDateInput;

                    DateTime endTimeInput = DateTime.ParseExact(endTime.Value, "HH:mm", CultureInfo.InvariantCulture);
                    if(endDate.SelectedDate == null || endDate.SelectedDate == DateTime.MinValue) {
                        endDateInput = new DateTime(startDate.SelectedDate.Year, startDate.SelectedDate.Month, startDate.SelectedDate.Day,
                        endTimeInput.Hour, endTimeInput.Minute, endTimeInput.Second);
                        repeatedEventEntity.ToDate = endDateInput;
                    } else {
                        endDateInput = new DateTime(endDate.SelectedDate.Year, endDate.SelectedDate.Month, endDate.SelectedDate.Day,
                        endTimeInput.Hour, endTimeInput.Minute, endTimeInput.Second);
                        repeatedEventEntity.ToDate = endDateInput;
                    }

                    repeatedEventEntity.Host = host.Value;
                    repeatedEventEntity.Topic = topic.Value;

                    bool result = false;
                    if(EventShouldRepeats()) {
                        List<DateTime> dates = showMultiple.Checked == true ? (List<DateTime>)ViewState["Dates"] : GetRepeateDates();

                        if(dates.Any(d => d.Date == eventEntity.FromDate.Date) && dates.Count > 1 && !showMultiple.Checked) {
                            dates.Remove(dates.Single(d => d.Date == eventEntity.FromDate.Date));
                        }

                        foreach(DateTime date in dates) {
                            repeatedEventEntity.FromDate = new DateTime(date.Year, date.Month, date.Day, startTimeInput.Hour, startTimeInput.Minute, startTimeInput.Second);
                            repeatedEventEntity.ToDate = new DateTime(date.Year, date.Month, date.Day, endTimeInput.Hour, endTimeInput.Minute, endTimeInput.Second);
                            result = eventRepository.Insert(dataAccess, repeatedEventEntity);
                            eventRepository.InsertEventRooms(dataAccess, GetSelectedRooms(), (int)eventRepository.LastInsertedId);
                        }
                    } else {
                        result = eventRepository.Insert(dataAccess, repeatedEventEntity);
                        eventRepository.InsertEventRooms(dataAccess, GetSelectedRooms(), (int)eventRepository.LastInsertedId);
                    }

                    dataAccess.StartTransaction();
                    dataAccess.Commit();
                } catch(SqlException exc) {
                    dataAccess.Rollback();
                } finally {
                    dataAccess.Close();
                }
            }

            System.Threading.Thread.Sleep(500);
            RegisterSweetAlertScriptOnSuccess();
        }
    }

    protected void EndTimeValidator(object sender, ServerValidateEventArgs e) {
        DateTime startTimeInput = DateTime.ParseExact(startTime.Value, "HH:mm", CultureInfo.InvariantCulture);
        DateTime endTimeInput = DateTime.ParseExact(endTime.Value, "HH:mm", CultureInfo.InvariantCulture);

        if(endTimeInput <= startTimeInput) {
            e.IsValid = false;
        } else {
            e.IsValid = true;
        }
    }

    private void DeleteEvent(int eventId) {
        DataAccess dataAccess = new DataAccess(DataAccess.GetWebConfigConnectionString("Infoskærm"));

        try {
            EventsRepository eventsRepository = new EventsRepository();
            dataAccess.Open();
            eventsRepository.Delete(dataAccess, eventId);
            dataAccess.Close();
        } catch(Exception exc) {
            dataAccess.Rollback();
        } finally {
            dataAccess.Close();
        }
    }

    private void UpdateEvent(EventEntity eventEntity) {
        DataAccess dataAccess = new DataAccess(DataAccess.GetWebConfigConnectionString("Infoskærm"));

        try {
            dataAccess.Open();

            EventsRepository eventRepository = new EventsRepository();

            bool result = eventRepository.Update(dataAccess, eventEntity);
            eventRepository.DeleteEventRooms(dataAccess, eventEntity.Id);
            eventRepository.InsertEventRooms(dataAccess, GetSelectedRooms(), eventEntity.Id);
            dataAccess.StartTransaction();
            dataAccess.Commit();
        } catch(Exception exc) {
            System.Diagnostics.Debug.WriteLine(exc);
            dataAccess.Rollback();
        } finally {
            dataAccess.Close();
        }
    }

    private List<int> GetSelectedRooms() {
        List<int> rooms = new List<int>();

        for(int i = 0; i < roomsSelect.Items.Count; i++) {
            if(roomsSelect.Items[i].Selected) {
                rooms.Add(int.Parse(roomsSelect.Items[i].Value));
            }
        }

        return rooms;
    }

    public EventEntity CreateEventEntityFromForm() {
        EventEntity eventEntity = new EventEntity();

        eventEntity.Id = int.Parse(eventID.Attributes["value"]);

        DateTime startTimeInput = DateTime.ParseExact(startTime.Attributes["value"], "HH:mm", CultureInfo.InvariantCulture);
        DateTime startDateInput = new DateTime(startDate.SelectedDate.Year, startDate.SelectedDate.Month, startDate.SelectedDate.Day,
            startTimeInput.Hour, startTimeInput.Minute, startTimeInput.Second);
        eventEntity.FromDate = startDateInput;

        DateTime endTimeInput = DateTime.ParseExact(endTime.Attributes["value"], "HH:mm", CultureInfo.InvariantCulture);
        DateTime endDateInput = new DateTime(startDate.SelectedDate.Year, startDate.SelectedDate.Month, startDate.SelectedDate.Day,
           endTimeInput.Hour, endTimeInput.Minute, endTimeInput.Second);
        eventEntity.ToDate = endDateInput;

        eventEntity.Host = host.Value;
        eventEntity.Topic = topic.Value;

        List<RoomEntity> rooms = new List<RoomEntity>();
        for(int i = 0; i < roomsSelect.Items.Count; i++) {
            if(roomsSelect.Items[i].Selected == true) {
                RoomEntity room = new RoomEntity();
                room.Id = int.Parse(roomsSelect.Items[i].Value);
                room.Identifier = roomsSelect.Items[i].Text;
                rooms.Add(room);
            }
        }
        eventEntity.Rooms = rooms;

        return eventEntity;
    }

    private void RegisterSweetAlertScriptOnSuccess() {
        ScriptManager.RegisterStartupScript(this, GetType(), "sweetalert", "swal('Aktiviteten blev ændret med succes');", true);
    }

    private void PopulateDepartmentsSelect(DataAccess dataAccess, EventsRepository repository) {
        List<DepartmentEntity> departments = repository.FetchAllDepartments(dataAccess);
        foreach(DepartmentEntity department in departments) {
            departmentsSelect.Items.Add(new ListItem(department.Name, department.Id.ToString()));
        }

        departmentsSelect.Items.FindByValue(eventEntity.Rooms[0].DepartmentId.ToString()).Selected = true;
    }

    private void SelectRooms(List<int> rooms) {
        foreach(int id in rooms) {
            ListItem item = roomsSelect.Items.FindByValue(id.ToString());
            if(item != null) {
                item.Selected = true;
            }
        }
    }

    private void SelectRooms(List<RoomEntity> rooms) {
        foreach(RoomEntity room in rooms) {
            ListItem item = roomsSelect.Items.FindByValue(room.Id.ToString());
            if(item != null) {
                item.Selected = true;
            }
        }
    }

    private void PopulateRoomsSelect(DataAccess dataAccess, EventsRepository repository, int departmentId) {
        List<RoomEntity> rooms = repository.FetchDepartmentRooms(dataAccess, departmentId);
        roomsSelect.Items.Clear();
        foreach(RoomEntity room in rooms) {
            roomsSelect.Items.Add(new ListItem(room.Identifier, room.Id.ToString()));
        }
    }

    private bool IsEventTarget(string Id) {
        if(Request.Params["__EVENTTARGET"] != null) {
            if(Request.Params["__EVENTTARGET"].ToString().Contains(Id)) {
                return true;
            }
        }

        return false;
    }

    protected void Calendar_DayRender1(object sender, DayRenderEventArgs e) {
        if(e.Day.Date < DateTime.Now.Date || e.Day.IsOtherMonth) {
            e.Day.IsSelectable = false;
            e.Cell.ForeColor = System.Drawing.Color.LightGray;
        }

        int weeknum = weekNumber.GetISO8601WeekNumber(e.Day.Date);
        string jscriptStartDate = "<script type='text/javascript'> addWkColumn('" + startDate.ClientID + "', " + weeknum + ");</script>";
        Page.ClientScript.RegisterStartupScript(this.GetType(), "AddWeeknumbersStartDate", jscriptStartDate);

    }

    protected void Calendar_DayRender2(object sender, DayRenderEventArgs e) {
        if(e.Day.Date < startDate.SelectedDate || e.Day.IsOtherMonth) {
            e.Day.IsSelectable = false;
            e.Cell.ForeColor = System.Drawing.Color.LightGray;
        }

        int weeknum = weekNumber.GetISO8601WeekNumber(e.Day.Date);
        string jscriptEndDate = "<script type='text/javascript'> addWkColumn('" + endDate.ClientID + "', " + weeknum + ");</script>";
        Page.ClientScript.RegisterStartupScript(this.GetType(), "AddWeeknumbersTilDato", jscriptEndDate);
    }


    private bool EventShouldRepeats() {
        List<int> repeatWeekDays = GetRepeatedWeekDays();
        if(repeatWeekDays.Count > 0 || showMultiple.Checked == true) {
            return true;
        }

        return false;
    }

    private List<DateTime> GetRepeateDates() {
        List<DateTime> dates = new List<DateTime>();

        DateTime startTimeInput = DateTime.ParseExact(startTime.Value, "HH:mm", CultureInfo.InvariantCulture);
        DateTime startDateInput = new DateTime(startDate.SelectedDate.Year, startDate.SelectedDate.Month, startDate.SelectedDate.Day,
            startTimeInput.Hour, startTimeInput.Minute, startTimeInput.Second);

        DateTime endTimeInput = DateTime.ParseExact(endTime.Value, "HH:mm", CultureInfo.InvariantCulture);
        DateTime endDateInput = new DateTime(endDate.SelectedDate.Year, endDate.SelectedDate.Month, endDate.SelectedDate.Day,
            endTimeInput.Hour, endTimeInput.Minute, endTimeInput.Second);

        List<int> repeatWeekDays = GetRepeatedWeekDays();
        for(DateTime date = startDateInput; date <= endDateInput; date = date.AddDays(1)) {
            if(repeatWeekDays.Contains((int)date.DayOfWeek)) {
                dates.Add(date);
            }
        }

        return dates;
    }

    private List<int> GetRepeatedWeekDays() {
        List<int> repeatWeekDays = new List<int>();
        for(int i = 0; i <= eventRepetitionSelect.Items.Count - 1; i++) {
            if(eventRepetitionSelect.Items[i].Selected) {
                if(int.Parse(eventRepetitionSelect.Items[i].Value) == 0) {
                    repeatWeekDays.Clear();
                    repeatWeekDays.AddRange(new List<int>() { 1, 2, 3, 4, 5 });
                    break;
                }
                repeatWeekDays.Add(int.Parse(eventRepetitionSelect.Items[i].Value));
            }
        }

        return repeatWeekDays;
    }

    protected void Calendar_DayRender3(object sender, DayRenderEventArgs e) {
        if(e.Day.Date < startDate.SelectedDate || e.Day.IsOtherMonth) {
            e.Day.IsSelectable = false;
            e.Cell.ForeColor = System.Drawing.Color.LightGray;
        }

        int weeknum = weekNumber.GetISO8601WeekNumber(e.Day.Date);
        string jscriptMultipleDatesCalender = "<script type='text/javascript'> addWkColumn('" + MultipleDatesCalender.ClientID + "', " + weeknum + ");</script>";
        Page.ClientScript.RegisterStartupScript(this.GetType(), "AddWeeknumbersMultipleDatesCalender", jscriptMultipleDatesCalender);
    }

    public List<DateTime> SelectedDates {
        get {
            if(ViewState["Dates"] != null) {
                return (List<DateTime>)ViewState["Dates"];
            } else {
                List<DateTime> dates = new List<DateTime>();
                dates.Add(startDate.SelectedDate);
                ViewState["Dates"] = dates;

                return (List<DateTime>)ViewState["Dates"];
            }
        }
        set {
            ViewState["Dates"] = value;
        }
    }
    protected void MultipleDatesCalender_PreRender(object sender, EventArgs e) {
        MultipleDatesCalender.SelectedDates.Clear();

        foreach(DateTime dt in SelectedDates) {
            MultipleDatesCalender.SelectedDates.Add(dt);
        }
    }
    protected void MultipleDatesCalender_SelectionChanged(object sender, EventArgs e) {
        if(SelectedDates.Contains(MultipleDatesCalender.SelectedDate)) {
            SelectedDates.Remove(MultipleDatesCalender.SelectedDate);
        } else {
            SelectedDates.Add(MultipleDatesCalender.SelectedDate);
        }

        ViewState["Dates"] = SelectedDates;
    }

    protected void btnClearSelection_Click(object sender, EventArgs e) {
        SelectedDates = null;
    }

}