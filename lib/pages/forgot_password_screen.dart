import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _emailController = TextEditingController();
    final _formKey = GlobalKey<FormState>(); // Agrega una clave global para el formulario

    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar contraseña'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey, // Asigna la clave global al formulario
            child: Column(
              children: [
                SizedBox(height: 20.0),
                Text(
                  'Ingresa el correo electrónico asociado a tu cuenta para recibir un enlace para restablecer tu contraseña.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'El correo electrónico es obligatorio';
                    }
                    // Verifica si el texto coincide con un formato de correo electrónico válido
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Implement your forgot password logic here (e.g., send an email with a reset link)
                      // ...
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Se ha enviado un correo electrónico con instrucciones para restablecer tu contraseña.'),
                        ),
                      );
                    }
                  },
                  child: Text('Enviar'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
