import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itm_connect/services/firestore_service.dart';

class FirestoreDebugScreen extends StatefulWidget {
  const FirestoreDebugScreen({super.key});

  @override
  State<FirestoreDebugScreen> createState() => _FirestoreDebugScreenState();
}

class _FirestoreDebugScreenState extends State<FirestoreDebugScreen> {
  final _svc = FirestoreService.instance;
  bool _busy = false;
  String? _lastDocId;
  String _status = 'Idle';

  Future<void> _addDummyNotice() async {
    setState(() {
      _busy = true;
      _status = 'Adding dummy notice...';
    });
    try {
      final id = await _svc.add('notices', {
        'title': 'Debug Notice',
        'body': 'This is a temporary debug notice',
        'createdAt': FieldValue.serverTimestamp(),
        'debug': true,
      });
      setState(() {
        _lastDocId = id;
        _status = 'Added notice with id: $id';
      });
    } catch (e) {
      setState(() {
        _status = 'Add failed: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _updateLastNotice() async {
    if (_lastDocId == null) {
      setState(() {
        _status = 'No last doc to update. Add first.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _status = 'Updating last notice...';
    });
    try {
      await _svc.set('notices', _lastDocId!, {
        'updatedAt': FieldValue.serverTimestamp(),
        'updated': true,
      });
      setState(() {
        _status = 'Updated notice: $_lastDocId';
      });
    } catch (e) {
      setState(() {
        _status = 'Update failed: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _readLastNotice() async {
    if (_lastDocId == null) {
      setState(() {
        _status = 'No last doc to read. Add first.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _status = 'Reading last notice...';
    });
    try {
      final snap = await _svc.get('notices', _lastDocId!);
      setState(() {
        _status = 'Read: ${snap.data()}';
      });
    } catch (e) {
      setState(() {
        _status = 'Read failed: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _deleteLastNotice() async {
    if (_lastDocId == null) {
      setState(() {
        _status = 'No last doc to delete. Add first.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _status = 'Deleting last notice...';
    });
    try {
      await _svc.delete('notices', _lastDocId!);
      setState(() {
        _status = 'Deleted notice: $_lastDocId';
        _lastDocId = null;
      });
    } catch (e) {
      setState(() {
        _status = 'Delete failed: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Debug'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _busy ? null : _addDummyNotice,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
                ElevatedButton.icon(
                  onPressed: _busy ? null : _readLastNotice,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Read'),
                ),
                ElevatedButton.icon(
                  onPressed: _busy ? null : _updateLastNotice,
                  icon: const Icon(Icons.system_update_alt),
                  label: const Text('Update'),
                ),
                ElevatedButton.icon(
                  onPressed: _busy ? null : _deleteLastNotice,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Status: $_status'),
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _svc.streamCollection(
                'notices',
                build: (q) => q
                    .where('debug', isEqualTo: true)
                    .orderBy('createdAt', descending: true)
                    .limit(25),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Stream error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No debug notices'));
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final id = docs[index].id;
                    return ListTile(
                      title: Text(data['title']?.toString() ?? 'Untitled'),
                      subtitle: Text('id: $id'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: _busy
                            ? null
                            : () async {
                                setState(() {
                                  _busy = true;
                                  _status = 'Deleting $id...';
                                });
                                try {
                                  await _svc.delete('notices', id);
                                  setState(() {
                                    _status = 'Deleted $id';
                                    if (_lastDocId == id) _lastDocId = null;
                                  });
                                } catch (e) {
                                  setState(() {
                                    _status = 'Delete failed: $e';
                                  });
                                } finally {
                                  setState(() {
                                    _busy = false;
                                  });
                                }
                              },
                      ),
                      onTap: () {
                        setState(() {
                          _lastDocId = id;
                          _status = 'Selected $id';
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
