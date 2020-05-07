import org.jpl7.Atom;
import org.jpl7.Query;
import org.jpl7.Term;
import org.jpl7.Util;
import org.jpl7.Variable;

//Connexion
String file = "prolog.pl"
java.util.Map<String, Term> sol;

int jeu(){
  Query q = new Query("consult", new Term[]{new Atom(file)});
}

String demandeIA = "";
q = new Query(demandeIA);

sol = q.oneSolution();

sol.get("rep").intValue();
