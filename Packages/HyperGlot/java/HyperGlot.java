import java.lang.*;
import hyperglot.Projects;

class HyperGlot {
	public static void main( String [] args ) {
		Projects projects = new Projects();
		String   selected = new String( projects.selectProject() );
		System.out.println( "SELECTED\t" + selected + "\n" );
	}
}
