package com.example.CollaborativeSport

import android.annotation.SuppressLint

class ConnectionWrapper @RequiresApi(api = Build.VERSION_CODES.S) constructor(context: Context) {
    private val TAG = "ConnectionWrapper"
    private val bluetoothAdapter: BluetoothAdapter
    private val context: Context
    var acceptThread: AcceptThread? = null
        private set
    private var connectThread: ConnectThread? = null
    private var bluetoothDevice: BluetoothDevice? = null
    private var deviceUUID: UUID? = null
    var connectedThread: ConnectedThread? = null
        private set

    /**
     * Thread that sits there at all times waiting for a connection.
     * Run on another thread so it does not use the main resources on the main activity thread.
     * Waits for something to try to connect to it.
     */
    inner class AcceptThread @RequiresApi(api = Build.VERSION_CODES.S) @SuppressLint("MissingPermission") constructor() :
        Thread() {
        // The local server socket
        private val serverSocket: BluetoothServerSocket?
        fun run() {
            Log.i(TAG, "Run Method of AcceptThread Called.")
            var socket: BluetoothSocket? = null
            try {
                // This is a blocking call and will only return on a
                // successful connection or an exception
                Log.i(
                    TAG,
                    "Starting the server socket of the AcceptThread to wait for a connection."
                )
                // Code will wait here until a connection is made or fails.
                socket = serverSocket.accept()
                Log.i(TAG, "AcceptThread accepted connection.")
            } catch (e: IOException) {
                Log.e(
                    TAG,
                    "AcceptThread: IOException: " + e.getMessage()
                        .toString() + " when attempting to accept a connection with the AcceptThread socket."
                )
            }

            // Socket is connected with Bluetooth Device.
            if (socket != null) {
                connected(socket)
            }
            Log.i(TAG, "End of Accept Thread. ")
        }

        fun cancel() {
            Log.i(TAG, "Canceling AcceptThread.")
            try {
                serverSocket.close()
            } catch (e: IOException) {
                Log.e(TAG, "Close of AcceptThread ServerSocket failed. " + e.getMessage())
            }
        }

        init {
            var temp: BluetoothServerSocket? = null
            try {
                temp = bluetoothAdapter.listenUsingInsecureRfcommWithServiceRecord(
                    "ConnectionWrapper",
                    "00001101-0000-1000-8000-00805F9B34FB"
                )
                Log.i(
                    TAG,
                    "AcceptThread: Creating Server Socket with UUID: " + "00001101-0000-1000-8000-00805F9B34FB"
                )
            } catch (e: IOException) {
                Log.e(TAG, "AcceptThread: IOException: " + e.getMessage())
            }
            serverSocket = temp
        }
    }

    /**
     * Both devices will be sitting in the accept thread state. Until another
     * device connect thread starts, it is going to grab the socket and connect to it.
     */
    private inner class ConnectThread(device: BluetoothDevice?, uuid: UUID?) : Thread() {
        private var socket: BluetoothSocket? = null

        // Automatically runs when executed.
        @RequiresApi(api = Build.VERSION_CODES.S)
        @SuppressLint("MissingPermission")
        fun run() {
            var temp: BluetoothSocket? = null
            Log.i(TAG, "RUN connectThread ")
            try {
                Log.i(
                    TAG,
                    "ConnectThread: Trying to create InsecureRfcommSocket using UUID: " + "00001101-0000-1000-8000-00805F9B34FB"
                )
                temp = bluetoothDevice.createRfcommSocketToServiceRecord(deviceUUID)
            } catch (e: IOException) {
                Log.e(TAG, "ConnectThread: Could not create InsecureRfcommSocket " + e.getMessage())
            }
            socket = temp

            // Always cancel discovery because it will slow down a connection. Memory intensive.
            bluetoothAdapter.cancelDiscovery()

            // Make a connection to the BluetoothSocket
            try {
                // This is a blocking call and will only return on a
                // successful connection or an exception
                socket.connect()
                // If it hits this log, it is passed the blocking call and it has been connected.
                Log.i(TAG, "run: ConnectThread connected. Device has connected to other device.")
            } catch (e: IOException) {
                // Close the socket
                try {
                    socket.close()
                    Log.i(TAG, "run: Closed Socket.")
                } catch (e1: IOException) {
                    Log.e(
                        TAG,
                        "connectThread: run: Unable to close connection in socket " + e1.getMessage()
                    )
                }
            }
            connected(socket)
        }

        fun cancel() {
            try {
                Log.d(TAG, "cancel: Closing Client Socket.")
                socket.close()
            } catch (e: IOException) {
                Log.e(TAG, "cancel: close() of socket in ConnectThread failed. " + e.getMessage())
            }
        }

        init {
            Log.i(TAG, "ConnectThread: started.")
            bluetoothDevice = device
            deviceUUID = uuid
        }
    }

    /**
     * Start acceptThread to sit and listen to connection.
     */
    @RequiresApi(api = Build.VERSION_CODES.S)
    @Synchronized
    fun start() {
        Log.i(TAG, "Starting AcceptThread")

        // Cancel any thread attempting to make a connection
        if (connectThread != null) {
            connectThread!!.cancel()
            connectThread = null
        }
        if (acceptThread == null) {
            acceptThread = AcceptThread()
            // This start is native to thread class.
            acceptThread.start()
        }
    }

    /**
     * Initiate Connect Thread
     */
    fun startClient(device: BluetoothDevice?, uuid: UUID?) {
        Log.i(TAG, "startClient: Started.")
        connectThread = ConnectThread(device, uuid)
        connectThread.start()
    }

    /**
     * Manages Connection. Point in time when connection has been made.
     */
    inner class ConnectedThread(socket: BluetoothSocket) : Thread() {
        private val socket: BluetoothSocket
        private val inputStream: InputStream?
        private val outputStream: OutputStream?
        fun run() {
            val buffer = ByteArray(1024) // buffer store for the stream
            var bytes: Int // bytes returned from read()

            // Keep listening to the InputStream until an exception occurs
            while (true) {
                // Read from the InputStream
                try {
                    bytes = inputStream.read(buffer)
                    val incomingData = String(buffer, 0, bytes)
                    Log.i(TAG, "InputStream: $incomingData")

                    // Passing data from the input stream to an activity.
                    val incomingDataIntent = Intent("incomingData")
                    incomingDataIntent.putExtra("data", incomingData)
                    LocalBroadcastManager.getInstance(context).sendBroadcast(incomingDataIntent)
                } catch (e: IOException) {
                    Log.e(TAG, "write: Error reading Input Stream. " + e.getMessage())
                    break
                }
            }
        }

        //Call this from the main activity to send data to the remote device
        fun write(bytes: ByteArray?) {
            val text = String(bytes, Charset.defaultCharset())
            Log.i(TAG, "write: Writing to outputstream: $text")
            try {
                outputStream.write(bytes)
            } catch (e: IOException) {
                Log.e(TAG, "write: Error writing to output stream. " + e.getMessage())
            }
        }

        /* Call this from the main activity to shutdown the connection */
        fun cancel() {
            try {
                socket.close()
            } catch (e: IOException) {
                Log.e(TAG, "Error in closing connectedThreadSocket")
            }
        }

        init {
            Log.i(TAG, "ConnectedThread: Starting.")
            this.socket = socket
            var tempInputStream: InputStream? = null
            var tempOutputStream: OutputStream? = null
            try {
                tempInputStream = this.socket.getInputStream()
                tempOutputStream = this.socket.getOutputStream()
            } catch (e: IOException) {
                Log.e(TAG, "Error in getting the socket's streams.")
                e.printStackTrace()
            }
            inputStream = tempInputStream
            outputStream = tempOutputStream
        }
    }

    private fun connected(socket: BluetoothSocket?) {
        Log.i(TAG, "connected: Starting.")

        // Start the method to manage the connection to perform output stream transmissions and grab input stream transmissions.
        connectedThread = ConnectedThread(socket)
        connectedThread.start()
    }

    /**
     * To access the connecedThread's write method in an unsynchronized manner.
     */
    fun write(out: ByteArray?) {
        // Synchronize a copy of the ConnectedThread
        Log.d(TAG, "write: Write Called.")
        //perform the write
        connectedThread!!.write(out)
    }

    init {
        this.context = context
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        start()
    }
}