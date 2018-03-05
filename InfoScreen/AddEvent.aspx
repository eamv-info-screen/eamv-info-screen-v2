<%@ Page Title="Opret aktivitet" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="AddEvent.aspx.cs" Inherits="AddEvent" %>

<asp:Content ID="mainContent" ContentPlaceHolderID="main" runat="Server">
    <div class="col-md-6 col-lg-offset-3 edit-event-content">
        <h3 class="text-center">Opret aktivitet</h3>
        <div class="col-md-6">
            <div class="form-group">
                <label for="topic">Emne *</label>
                <asp:RequiredFieldValidator runat="server" ID="emptyTopic" ControlToValidate="topic" ErrorMessage="Dette felt er obligatorisk" ForeColor="Red" />
                <input type="text" class="form-control" id="topic" placeholder="Emne" runat="server" />
            </div>
        </div>

        <div class="col-md-6">
            <div class="form-group">
                <label for="host">v/hvem</label>
                <input type="text" class="form-control" id="host" placeholder="v/hvem" runat="server" />
            </div>
        </div>
        <% if(showMultiple.Checked != true) { %>
        <div class="col-md-6 col-lg-offset-3">
            <div class="form-group">
                <label>Start dato</label><span runat="server" id="startDatoWarning" style="color: red; visibility: hidden;"> Advarsel! Datoen ligger langt ude i fremtiden.</span>
                <asp:Calendar CssClass="event-calendar" ID="startDate" runat="server" OnDayRender="Calendar_DayRender1">
                    <OtherMonthDayStyle ForeColor="LightGray"></OtherMonthDayStyle>
                    <TitleStyle CssClass="month"></TitleStyle>
                    <DayStyle CssClass="event-calendar-day"></DayStyle>
                    <SelectedDayStyle CssClass="calendar-date-selected"></SelectedDayStyle>
                </asp:Calendar>
            </div>
        </div>
        <% } %>

        <div class="col-md-6">
            <div class="form-group">
                <label for="startTime">Start tidspunkt *</label>
                <asp:CustomValidator ID="CustomValidator1" ForeColor="Red" runat="server" />
                <asp:RequiredFieldValidator runat="server" ID="emptyStartTime" Display="Dynamic" ControlToValidate="startTime" ErrorMessage="Dette felt er obligatorisk" ForeColor="Red" />
                <input type="text" id="startTime" class="form-control timepickerStart" name="timepickerStart" runat="server" />
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
                <input type="text" id="endTime" class="form-control timepickerEnd" name="timepickerEnd" runat="server" />
            </div>
            <div class="form-group white-select">
                <label for="rooms">Lokale *</label>
                <asp:RequiredFieldValidator runat="server" ID="notChosenRoom" ControlToValidate="roomsSelect" ErrorMessage="Dette felt er obligatorisk" ForeColor="Red" />
                <select class="form-control selectpicker" data-none-selected-text="Vælg lokale" multiple id="roomsSelect" runat="server">
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
            <input type="hidden" value="" />
            <button id="submitButton" type="submit" class="btn pull-right btn-warning" runat="server" onserverclick="OnFormSubmit">Opret</button>
        </div>
    </div>
</asp:Content>
