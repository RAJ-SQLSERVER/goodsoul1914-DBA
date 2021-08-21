/****************************************************************************/
/*                    Blocking Monitoring Framework                         */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                http://aboutsqlserver.com/bmframework                     */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*                              Initial Setup                               */
/*						     Set Version Number                             */
/****************************************************************************/

USE DBA;
GO

EXEC dbo.SetVersion @Product = 'bmframework', @Version = '1.0.0';
