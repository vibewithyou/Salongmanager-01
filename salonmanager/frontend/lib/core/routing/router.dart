// go_router configuration with three routes: /, /login, /salon/:id
// Screens are placeholders for now

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget _placeholderScreen(String title) => Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );

GoRouter buildRouter() {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => _placeholderScreen('Home'),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => _placeholderScreen('Login'),
      ),
      GoRoute(
        path: '/salon/:id',
        name: 'salon',
        builder: (context, state) => _placeholderScreen('Salon \\${state.pathParameters['id']}'),
      ),
    ],
  );
}

