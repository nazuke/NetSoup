/*
 *    This class is responsible for selecting a HyperGlot project
 *    from the projects available on the HyperGlot server.
 */

package hyperglot;

import java.lang.*;
import java.net.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.widgets.*;


public class Projects {

	private String HOSTNAME = "localhost";  // Define HyperGlot server hostname
	private int    PORT     = 1702;         // Define the HyperGlot server port

	public String selectProject() {
		ProjectChooser chooser  = new ProjectChooser();  //
		StringBuffer[] projects;
		int            number   = getNumberProjects();   //
		int            index    = 0;
		String         selected = "";
		if( number < 0 ) return( "" );
		projects = new StringBuffer[number+1];           // Initialise project list
		getProjectList( number, projects );
		for( int i = 0 ; i <= number ; i++ )
			System.out.println( projects[i] );
		index    = chooser.chooser( number, projects );  // Pick project from AWT list
		selected = new String( projects[index] );
		return( selected );
	}

	private int getNumberProjects() {
		Socket       socket;
		InputStream  input;
		OutputStream output;
		byte[]       signature = { 78, 85, 77, 66,    // Signature : NUMBPROJ
															 80, 82, 79, 74 };
		int          number    = -1;                  // Holds number of projects
		try {
			socket = new Socket( HOSTNAME, PORT );
			input  = socket.getInputStream();
			output = socket.getOutputStream();
			output.write( signature );                  // Select NUMBPROJ function...
			number = input.read();                      // Get number of projects : max 255
			socket.close();
		} catch( java.io.IOException e ) {
			return(-1);                                 // Return on error
		}
		return( number );
	}

	private boolean getProjectList( int number, StringBuffer[] projects ) {
		Socket       socket;
		InputStream  input;
		OutputStream output;
		byte[]       signature = { 76, 73, 83, 84,      // Signature : LISTPROJ
															 80, 82, 79, 74 };
		try {
			socket = new Socket( HOSTNAME, PORT );
			input  = socket.getInputStream();
			output = socket.getOutputStream();
			output.write( signature );                    // Select LISTPROJ function...
		} catch( java.io.IOException e ) {
			return( false );                              // Return on error
		}
		for( int i = 0 ; i <= number ; i++ ) {
			int          c     = 0;
			boolean      stop  = false;
			StringBuffer entry = new StringBuffer( "" );  //
			do {
				try {
					c = input.read();
				} catch( java.io.IOException e ) {
					return( false );
				}
				if( c == 10 ) stop = true;
				entry.append( (char) c );
			} while( stop == false );
			projects[i] = entry;
		}
		try {
			socket.close();
		} catch( java.io.IOException e ) {
			return( false );
		}
		return( true );
	}

}


public class ProjectChooser extends Frame implements ActionListener {

	private int chosen = -1;

	public int chooser( int number, StringBuffer[] projects ) {
		Frame  win     = new Frame( "Choose Project" );
		Panel  buttons = new Panel();
		Choice listbox = new Choice();
		Button ok      = new Button( "OK" );
		Button cancel  = new Button( "Cancel" );
		win.setLayout( new GridLayout( 2, 1 ) );
		win.setSize( 320, 240 );
		for( int i = 0 ; i <= number ; i++ ) {
			String entry = new String( projects[i] );
			listbox.add( entry );
		}
		win.add( listbox );
		ok.addActionListener( this );
		cancel.addActionListener( this );
		buttons.add( ok );
		buttons.add( cancel );
		win.add( buttons );
		win.show();
		return( this.chosen );
	}

	public void actionPerformed( ActionEvent e ) {
		System.out.println( "Event\t" + e );
		this.chosen = 1;
	}

}
