import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/image.widget/image.widget.dart';
import '../../shared/image_process/pick.photo.dart';
import 'provider.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key, required this.isEditable});

  final bool isEditable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!isEditable)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => ref
                  .read(profileProvider(isEditable).notifier)
                  .toggleEditable(),
            ),
        ],
      ),
      body: Center(
        child: Container(
          width: min(400, MediaQuery.of(context).size.width - 40.0),
          margin: const EdgeInsets.all(20.0),
          child: ref.watch(profileProvider(isEditable)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (_) {
                  final notifier =
                      ref.read(profileProvider(isEditable).notifier);
                  return Form(
                    key: notifier.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(100.0),
                          onTap: !notifier.isEditable
                              ? null
                              : () async => await pickPhoto(context).then((pk) {
                                    if (pk == null) return;
                                    notifier.setImage(pk);
                                  }),
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 2.0,
                                  ),
                                ),
                                child: notifier.user != null &&
                                        notifier.image == null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: Image.network(
                                          notifier.user?.img ??
                                              'https://via.placeholder.com/150',
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, p) =>
                                              p == null
                                                  ? child
                                                  : const CircularProgressIndicator(),
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.error),
                                        ),
                                      )
                                    : notifier.image != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: ImageWidget(notifier.image!),
                                          )
                                        : Icon(
                                            Icons.add,
                                            size: 60.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                              ),
                              if (notifier.user != null && notifier.isEditable)
                                Positioned(
                                  bottom: 3,
                                  right: 3,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(100.0),
                                    onTap: () async =>
                                        await pickPhoto(context).then((pk) {
                                      if (pk == null) return;
                                      notifier.setImage(pk);
                                    }),
                                    child: Container(
                                      padding:
                                          const EdgeInsetsDirectional.all(4.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 14.0,
                                      ),
                                    ),
                                  ),
                                ),
                              if (notifier.image != null && notifier.isEditable)
                                Positioned(
                                  top: 3,
                                  right: 3,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(100.0),
                                    onTap: () => notifier.removeImage(),
                                    child: Container(
                                      padding:
                                          const EdgeInsetsDirectional.all(3.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        size: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50.0),
                        TextFormField(
                          enabled: false,
                          initialValue: FirebaseAuth
                                  .instance.currentUser?.email ??
                              FirebaseAuth.instance.currentUser?.phoneNumber ??
                              'No identifier found!',
                          decoration: const InputDecoration(
                            labelText: 'Identifier',
                            prefixIcon: Icon(Icons.location_history_outlined),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: notifier.nameCntrlr,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your full name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          enabled: notifier.isEditable,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value!.isEmpty) return 'Name cannot be empty!';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        if (notifier.isEditable)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => notifier.submit(context),
                                  child: notifier.isLoading
                                      ? Container(
                                          padding: const EdgeInsets.all(4.0),
                                          alignment: Alignment.center,
                                          child:
                                              const CircularProgressIndicator())
                                      : Text(
                                          notifier.isEditable ? 'Save' : 'Edit',
                                        ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }
}
