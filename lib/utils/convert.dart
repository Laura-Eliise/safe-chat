class Convert {
  static String encrypt(String data) => data.replaceAll(".", ":");
  static String decrypt(String data) => data.replaceAll(":", ".");
}