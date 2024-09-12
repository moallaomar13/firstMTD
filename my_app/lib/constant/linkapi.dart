const String baseUrl = "http://localhost/phptest/newdb";
//Auth 
const String linkSignUp ="http://localhost/phptest/newdb/signup.php";
const String linklogin ="http://localhost/phptest/newdb/users.php";
class ApiLinks {
  // Base URL for the server



  // Users endpoints
  static const String createUser = "$baseUrl/users.php"; // For creating a user
  static const String readUser = "$baseUrl/users.php";   // For reading users (use query parameters for specific IDs)
  static const String updateUser = "$baseUrl/users.php"; // For updating a user
  static const String deleteUser = "$baseUrl/users.php"; // For deleting a user

  // Terrains endpoints
  static const String createTerrain = "$baseUrl/terrains.php"; // For creating a terrain
  static const String readTerrain = "$baseUrl/terrains.php";   // For reading terrains (use query parameters for specific IDs)
  static const String updateTerrain = "$baseUrl/terrains.php"; // For updating a terrain
  static const String deleteTerrain = "$baseUrl/terrains.php"; // For deleting a terrain

  // Categories endpoints
  static const String createCategory = "$baseUrl/categories.php"; // For creating a category
  static const String readCategory = "$baseUrl/categories.php";   // For reading categories (use query parameters for specific IDs)
  static const String updateCategory = "$baseUrl/categories.php"; // For updating a category
  static const String deleteCategory = "$baseUrl/categories.php"; // For deleting a category

  // Terrain Categories endpoints
  static const String createTerrainCategory = "$baseUrl/terrain_categories.php"; // For creating a terrain category
  static const String readTerrainCategory = "$baseUrl/terrain_categories.php";   // For reading terrain categories (use query parameters for specific IDs)
  static const String updateTerrainCategory = "$baseUrl/terrain_categories.php"; // For updating a terrain category
  static const String deleteTerrainCategory = "$baseUrl/terrain_categories.php"; // For deleting a terrain category

  // Reservations endpoints
  static const String createReservation = "$baseUrl/reservations.php"; // For creating a reservation
  static const String readReservation = "$baseUrl/reservations.php";   // For reading reservations (use query parameters for specific IDs)
  static const String updateReservation = "$baseUrl/reservations.php"; // For updating a reservation
  static const String deleteReservation = "$baseUrl/reservations.php"; // For deleting a reservation

  // Timeslots endpoints
  static const String createTimeslot = "$baseUrl/timeslots.php"; // For creating a timeslot
  static const String readTimeslot = "$baseUrl/timeslots.php";   // For reading timeslots (use query parameters for specific IDs)
  static const String updateTimeslot = "$baseUrl/timeslots.php"; // For updating a timeslot
  static const String deleteTimeslot = "$baseUrl/timeslots.php"; // For deleting a timeslot


  // Timeslots endpoints
  static const String createreservationTimeslot = "$baseUrl/reservation_timeslot.php"; // For creating a reservation_timeslot
  static const String readreservationTimeslot = "$baseUrl/reservation_timeslot.php";   // For reading reservation_timeslots (use query parameters for specific IDs)
  static const String updatereservationTimeslot = "$baseUrl/reservation_timeslot.php"; // For updating a reservation_timeslot
  static const String deletereservationTimeslot = "$baseUrl/reservation_timeslot.php"; // For deleting a reservation_timeslot
}
