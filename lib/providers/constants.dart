const double kFieldHeight = 40;
List<Map<String, dynamic>> selectedApartmentRoomList =[];
List<Map<String, dynamic>> selectedRoomList =[];
int unreadCount = 0;
int ideaTimeDuration = 15;
Map<String, dynamic> usersData = {
  "tenants": 0,
  "staff": 0,
  "artisans": 0,
  "total": 0,
};

Map<String, dynamic> maintenanceData = {
  "total": 0,
  "open": 0,
  "completed": 0,
  "overdue": 0,
  "completion_rate": 0,
};

Map<String, dynamic> priorityBreakdown = {
  "low": 0,
  "medium": 0,
  "high": 0,
};

Map<String, dynamic> statusBreakdown = {
  "Pending": 0,
  "Assigned": 0,
  "In progress": 0,
  "Completed": 0,
  "Cancelled": 0,
};