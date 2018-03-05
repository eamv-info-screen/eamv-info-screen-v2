<%@ Page Title="Klon aktivitet" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="CloneEvent.aspx.cs" Inherits="CloneEvent" %>

<asp:Content ID="mainContent" ContentPlaceHolderID="main" runat="Server">
    <div class="col-md-6 col-lg-offset-3 edit-event-content">
        <h3 class="text-center">Klon aktivitet</h3>
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
        <div class="col-md-12">
            <input type="hidden" value="" />
            <button type="submit" id="submitButton" class="btn pull-right btn-warning" runat="server" onserverclick="OnFormSubmit">Gem</button>
        </div>
    </div>
</asp:Content>
