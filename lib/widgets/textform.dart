import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  bool isPassword = false,
  int? newMaxLines ,
  bool isEnable = true,
  int? newMaxLength ,
  Function(String value)? onChangeAction,
}) {
  return TextFormField(
    maxLines:newMaxLines,
    maxLength:newMaxLength ,
    controller: controller,
    enabled:isEnable ,
    keyboardType: keyboardType,
    obscureText: isPassword,

    style: const TextStyle(
      fontSize: 12,
      color: Colors.black,
    ),

    decoration: InputDecoration(
      labelText: label,
      counterText: '',
      labelStyle: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(
          icon,
          color: Colors.grey,
          size: 18,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 40,
      ),
      isDense: true, // 🔑 makes field shorter
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:  EdgeInsets.symmetric(
        horizontal: 12,
        vertical:newMaxLines !=null ?24: 8, // 🔑 reduced height
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red),
      ),
    ),
    onChanged: onChangeAction,
  );
}

Widget passwordField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  required bool isHidden,
  required VoidCallback onToggle,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: isHidden,
    maxLines: 1,
    style: const TextStyle(fontSize: 12, color: Colors.black),

    decoration: InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(icon, color: Colors.grey,  size: 18,),
      ),

      suffixIcon:
      GestureDetector(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            isHidden
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 16,
            color: Colors.grey,
          ),
        ),
      ),



      prefixIconConstraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 35,
      ),
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8, // 🔑 reduced height
      ),
      isDense: true, // 🔑 makes field shorter
      filled: true,
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red),
      ),

    ),
  );
}

