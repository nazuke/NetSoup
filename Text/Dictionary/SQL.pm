#!/usr/local/bin/perl
#
#   NetSoup::Text::Dictionary::SQL.pm v00.00.01b 12042000
#
#   Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#   Description: This Perl 5.0 class provides SQL language keyword support
#                for the NetSoup::Text::Dictionary class library.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class
#       BEGIN       -  This method is the class constructor for this class


package NetSoup::Text::Dictionary::SQL;
use strict;
use NetSoup::Core;
use NetSoup::Text::Dictionary;
@NetSoup::Text::Dictionary::SQL::ISA    = qw( NetSoup::Core
                                              NetSoup::Text::Dictionary );
$NetSoup::Text::Dictionary::SQL::Inited = 0;   # Mark dictionary list as uninitialised
%NetSoup::Text::Dictionary::SQL::List   = ();  # Create empty class global dictionary list
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object      = shift;                                  # Get object
  $object->{List} = %NetSoup::Text::Dictionary::SQL::List;  # Assign global dictionary list
  return(1) if( $NetSoup::Text::Dictionary::SQL::Inited );  # Return if dictionary already initialised
  while( <NetSoup::Text::Dictionary::SQL::DATA> ) {         # Load words
    chomp;
    $object->{List}->{$_} = $_ if( $_ );                    # Add word to list
  }
  $NetSoup::Text::Dictionary::SQL::Inited++;                # Mark dictionary list as initialised
  return(1);
}


sub lookup {
  # This method overrides the default lookup() method,
  # it determines if a word is in the dictionary.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Word => $word
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object = shift;                      # Get object
  my %args   = @_;                         # Get arguments
  my $word   = $args{Word};                # Get word to look up
  $word      =~ s/^\s+//s;
  $word      =~ s/\s+$//s;
  if( exists $object->{List}->{$word} ) {  # Look for word in dictionary
    return(1);
  } else {
    return(0);
  }
}


__DATA__
ABSOLUTE
ACQUIRE
ACTION
ADD
ALL
ALLOCATE
ALTER
AND
ANY
ARE
AS
ASC
ASSERTION
AT
AUDIT
AUTHORIZATION
AVG
BEGIN
BETWEEN
BIT_LENGTH
BOTH
BUFFERPOOL
BY
CALL
CAPTURE
CASCADED
CASE
CAST
CATALOG
CCSID
CHAR
CHARACTER
CHARACTER_LENGTH
CHAR_LENGTH
CHECK
CLOSE
CLUSTER
COALESCE
COLLATE
COLLATION
COLLECTION
COLUMN
COMMENT
COMMIT
CONCAT
CONNECT
CONNECTION
CONSTRAINT
CONSTRAINTS
CONTINUE
CONVERT
CORRESPONDING
COUNT
CREATE
CROSS
CURRENT
CURRENT_DATE
CURRENT_SERVER
CURRENT_TIME
CURRENT_TIMESTAMP
CURRENT_TIMEZONE
CURRENT_USER
CURSOR
DATABASE
DATE
DAY
DAYS
DBA
DBSPACE
DEALLOCATE
DEC
DECIMAL
DECLARE
DEFAULT
DEFERRABLE
DEFERRED
DELETE
DESC
DESCRIBE
DESCRIPTOR
DIAGNOSTICS
DISCONNECT
DISTINCT
DOMAIN
DOUBLE
DROP
EDITPROC
ELSE
END
END-EXEC
ERASE
ESCAPE
EXCEPT
EXCEPTION
EXCLUSIVE
EXECUTE
EXISTS
EXPLAIN
EXTERNAL
EXTRACT
FALSE
FETCH
FIELDPROC
FIRST
FLOAT
FOR
FOREIGN
FOUND
FROM
FULL
GET
GLOBAL
GO
GOTO
GRANT
GRAPHIC
GROUP
HAVING
HOUR
HOURS
IDENTIFIED
IDENTITY
IMMEDIATE
IN
INDEX
INDICATOR
INITIALLY
INNER
INOUT
INPUT
INSENSITIVE
INSERT
INTERSECT
INTERVAL
INTO
IS
ISOLATION
JOIN
KEY
LABEL
LANGUAGE
LAST
LEADING
LEFT
LEVEL
LIKE
LOCAL
LOCK
LOCKSIZE
LONG
LOWER
MATCH
MAX
MICROSECOND
MICROSECONDS
MIN
MINUTE
MINUTES
MODE
MODULE
MONTH
MONTHS
NAMED
NAMES
NATIONAL
NATURAL
NCHAR
NEXT
NHEADER
NO
NOT
NULL
NULLIF
NUMERIC
NUMPARTS
OBID
OCTET_LENGTH
OF
ON
ONLY
OPEN
OPTIMIZE
OPTION
OR
ORDER
OUT
OUTER
OUTPUT
OVERLAPS
PACKAGE
PAD
PAGE
PAGES
PART
PARTIAL
PCTFREE
PCTINDEX
PLAN
POSITION
PRECISION
PREPARE
PRESERVE
PRIMARY
PRIOR
PRIQTY
PRIVATE
PRIVILEGES
PROCEDURE
PROGRAM
PUBLIC
READ
REAL
REFERENCES
RELATIVE
RELEASE
RESET
RESOURCE
REVOKE
RIGHT
ROLLBACK
ROW
ROWS
RRN
RUN
SCHEDULE
SCHEMA
SCROLL
SECOND
SECONDS
SECQTY
SECTION
SELECT
SESSION
SESSION_USER
SET
SHARE
SIMPLE
SIZE
SMALLINT
SOME
SPACE
SQL
SQLCODE
SQLERROR
SQLSTATE
STATISTICS
STOGROUP
STORPOOL
SUBPAGES
SUBSTRING
SUM
SYNONYM
SYSTEM_USER
TABLE
TABLESPACE
TEMPORARY
THEN
TIMEZONE_HOUR
TIMEZONE_MINUTE
TO
TRAILING
TRANSACTION
TRANSLATION
TRIM
TRUE
UNION
UNIQUE
UNKNOWN
UPDATE
UPPER
USAGE
USER
USING
VALIDPROC
VALUE
VALUES
VARCHAR
VARIABLE
VARYING
VCAT
VIEW
VOLUMES
WHEN
WHENEVER
WHERE
WITH
WORK
WRITE
YEAR
YEARS
ZONE
