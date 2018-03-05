<%@ Page Title="Ændre aktivitet" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="EditEvent.aspx.cs" Inherits="EditEvent" %>

<asp:Content ID="mainContent" ContentPlaceHolderID="main" runat="Server">
    <div class="col-md-6 col-lg-offset-3 edit-event-content">
        <h3 class="text-center">Ændre aktivitet</h3>
        <div>
            <h4 class="canceled-event text-center" runat="server" id="canceled" visible="false">Dette event er aflyst!</h4>
        </div>
        <div class="col-md-6">
            <div class="form-group">
                <label for="topic">Emne *</label>
                <asp:RequiredFieldValidator runat="server" ID="emptyTopic" ControlToValidate="topic" ErrorMessage="Dette felt er obligatorisk" ForeColor="Red" />
                <input type="text" class="form-control" id="topic" placeholder="Emne" runat="server"
                    value="<%# eventEntity.Topic %>" />
            </div>
        </div>

        <div class="col-md-6">
            <div class="form-group">
                <label for="host">v/hvem</label>
                <input type="text" class="form-control" id="host" placeholder="v/hvem" runat="server"
                    value="<%# eventEntity.Host %>" />
            </div>
        </div>

        <% if(showMultiple.Checked != true) { %>
        <div class="col-md-6 col-lg-offset-3">
            <div class="form-group">
                <label>Dato *</label>
                <asp:Calendar CssClass="event-calendar" ID="startDate" OnDayRender="Calendar_DayRender1" runat="server">
                    <OtherMonthDayStyle ForeColor="LightGray"></OtherMonthDayStyle>
                    <TitleStyle CssClass="month"></TitleStyle>
                    <DayStyle CssClass="event-calendar-day"></DayStyle>
                    <SelectedDayStyle CssClass="calendar-date-selected"></SelectedDayStyle>
                </asp:Calendar>
            </div>
        </div>
        <% } %>

        <div class="col-md-6">
            <div class="form-group ">
                <label for="startTime">Start tidspunkt *</label>
                <asp:CustomValidator ID="CustomValidator1" ForeColor="Red" runat="server" />
                <asp:RequiredFieldValidator runat="server" Display="Dynamic" ID="emptyStartTime" ControlToValidate="startTime" ErrorMessage="Dette felt er obligatorisk" ForeColor="Red" />
                <input type="text" id="startTime" class="form-control timepickerStart" name="timepickerStart" runat="server"
                    value='<%# eventEntity.FromDate.ToString("HH:mm") %>' />
            </div>
            <div class="form-group white-select">
                <label for="rooms">Afdeling *</label>
                <asp:DropDownList class="form-control selectpicker show-tick" ID="departmentsSelect" AutoPostBack="true" runat="server">
                </asp:DropDownList>
            </div>
        </div>
        <div class="col-md-6">
            <div class="form-group">
                <label for="endTime">Slut tidspunkt *</label>
                <asp:CustomValidator ID="endTimeValidator" Display="Dynamic" ControlToValidate="endTime" OnServerValidate="EndTimeValidator" ErrorMessage="skal være efter start tidspunkt" ForeColor="Red" runat="server" />
                <asp:RequiredFieldValidator runat="server" Display="Dynamic" ID="emptyEndTime" ControlToValidate="endTime" ErrorMessage="Dette felt er obligatorisk" ForeColor="Red" />
                <input type="text" id="endTime" class="form-control timepickerEnd" name="timepickerEnd" runat="server"
                    value='<%# eventEntity.ToDate.ToString("HH:mm") %>' />
            </div>
            <div class="form-group white-select">
                <label for="rooms">Lokale *</label>
                <asp:RequiredFieldValidator runat="server" ID="notChosenRoom" ControlToValidate="roomsSelect" ErrorMessage="Dette felt er obligatorisk" ForeColor="Red" />
                <select class="form-control roomsSelect selectpicker" id="roomsSelect" data-none-selected-text="Vælg lokale" runat="server" multiple>
                </select>
            </div>
        </div>

        <div class="col-md-6 col-lg-offset-3">
            <h3 class="text-center">Adskillige datoer/dage</h3>
        </div>

        <% if(showMultiple.Checked == true) { %>
        <div class="col-md-6 col-lg-offset-3">
            <div class="form-group">
                <label>Datoer for aktivitet</label>
                <asp:Calendar CssClass="event-calendar" ID="MultipleDatesCalender" runat="server" OnPreRender="MultipleDatesCalender_PreRender" OnSelectionChanged="MultipleDatesCalender_SelectionChanged" OnDayRender="Calendar_DayRender3">
                    <OtherMonthDayStyle ForeColor="LightGray"></OtherMonthDayStyle>
                    <TitleStyle CssClass="month"></TitleStyle>
                    <DayStyle CssClass="event-calendar-day"></DayStyle>
                    <SelectedDayStyle CssClass="calendar-date-selected"></SelectedDayStyle>
                </asp:Calendar>
            </div>
        </div>
        <% } %>

        <%if(showMultiple.Checked == false) { %>
        <div class="col-md-6 col-lg-offset-3 repeatDates">
            <div class="form-group">
                <div class="form-group white-select">
                    <label for="rooms">Gentagelse</label>
                    <select class="form-control selectpicker" data-none-selected-text="Vælg gentagelses periode" multiple id="eventRepetitionSelect" runat="server">
                        <option value="0">Hver dag</option>
                        <option value="1">Hver mandag</option>
                        <option value="2">Hver tirsdag</option>
                        <option value="3">Hver onsdag</option>
                        <option value="4">Hver torsdag</option>
                        <option value="5">Hver fredag</option>
                    </select>
                </div>
            </div>
        </div>
        <% } %>

        <div class="col-md-2">
            <label>Valgfri datoer</label>
            <br />
            <label>
                <asp:CheckBox runat="server" ID="showMultiple" type="checkbox" AutoPostBack="true" />
            </label>
        </div>

        <%if(showMultiple.Checked == false) { %>
        <div class="col-md-6 col-lg-offset-3 repeatDates">
            <div class="form-group">
                <label>Slut dato</label>
                <asp:Calendar CssClass="event-calendar" ID="endDate" runat="server" OnDayRender="Calendar_DayRender2">
                    <OtherMonthDayStyle ForeColor="LightGray"></OtherMonthDayStyle>
                    <TitleStyle CssClass="month"></TitleStyle>
                    <DayStyle CssClass="event-calendar-day"></DayStyle>
                    <SelectedDayStyle CssClass="calendar-date-selected"></SelectedDayStyle>
                </asp:Calendar>
            </div>
        </div>
        <% } %>

        <div class="col-md-12">
            <input type="hidden" name="eventID" id="eventID" value='<%# eventEntity.Id %>' runat="server" />
            <button type="submit" id="submitButton" class="btn pull-right btn-warning" runat="server" onserverclick="OnFormSubmit">Gem</button>
        </div>
    </div>
</asp:Content>
