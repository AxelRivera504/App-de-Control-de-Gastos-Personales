import 'package:flutter/material.dart';

class IconHelper {
  
  /// Convierte un string a IconData para usar en las transacciones
  static IconData getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      // Iconos de trabajo/ingresos
      case 'work':
      case 'trabajo':
        return Icons.work;
      
      case 'monetization_on':
      case 'dinero':
        return Icons.monetization_on;
      
      case 'payment':
      case 'pago':
        return Icons.payment;
      
      case 'trending_up':
      case 'aumento':
        return Icons.trending_up;
        
      case 'account_balance_wallet':
      case 'billetera':
        return Icons.account_balance_wallet;
      
      // Iconos de gastos
      case 'shopping_cart':
      case 'supermercado':
      case 'compras':
        return Icons.shopping_cart;
      
      case 'home':
      case 'casa':
      case 'alquiler':
        return Icons.home;
      
      case 'local_gas_station':
      case 'transporte':
      case 'combustible':
        return Icons.local_gas_station;
      
      case 'restaurant':
      case 'comida':
      case 'restaurante':
        return Icons.restaurant;
        
      case 'shopping_bag':
      case 'bolsa':
        return Icons.shopping_bag;
        
      case 'local_grocery_store':
      case 'tienda':
        return Icons.local_grocery_store;
        
      case 'medical_services':
      case 'salud':
        return Icons.medical_services;
        
      case 'school':
      case 'educacion':
        return Icons.school;
        
      case 'phone':
      case 'telefono':
        return Icons.phone;
        
      case 'electric_bolt':
      case 'electricidad':
        return Icons.electric_bolt;
        
      case 'sports_esports':
      case 'entretenimiento':
        return Icons.sports_esports;
        
      case 'fitness_center':
      case 'gimnasio':
        return Icons.fitness_center;
        
      case 'pets':
      case 'mascotas':
        return Icons.pets;
        
      case 'flight':
      case 'viajes':
        return Icons.flight;
        
      case 'card_giftcard':
      case 'regalos':
        return Icons.card_giftcard;
        
      case 'local_laundry_service':
      case 'limpieza':
        return Icons.local_laundry_service;
        
      case 'directions_car':
      case 'auto':
        return Icons.directions_car;
        
      case 'savings':
      case 'ahorros':
        return Icons.savings;
        
      // Icono por defecto
      default:
        return Icons.category;
    }
  }
  
  /// Lista de iconos comunes con sus nombres para usar en selecciones
  static final Map<String, IconData> commonIcons = {
    'trabajo': Icons.work,
    'dinero': Icons.monetization_on,
    'pago': Icons.payment,
    'billetera': Icons.account_balance_wallet,
    'supermercado': Icons.shopping_cart,
    'casa': Icons.home,
    'transporte': Icons.local_gas_station,
    'comida': Icons.restaurant,
    'salud': Icons.medical_services,
    'educacion': Icons.school,
    'telefono': Icons.phone,
    'entretenimiento': Icons.sports_esports,
    'viajes': Icons.flight,
    'auto': Icons.directions_car,
    'ahorros': Icons.savings,
  };
  
  /// Obtiene el nombre string de un IconData (útil para guardar en Firebase)
  static String getStringFromIcon(IconData icon) {
    for (var entry in commonIcons.entries) {
      if (entry.value == icon) {
        return entry.key;
      }
    }
    return 'category'; // default
  }
}