<?php

namespace NickyDigital\PhotoboothBundle\Entity;

use FOS\UserBundle\Entity\User as BaseUser;
use Doctrine\ORM\Mapping as ORM;

/**
 * User: T. Curran
 * Date: 2/9/13
 *
 * @ORM\Table()
 * @ORM\Entity
 */
class User extends BaseUser
{
	/**
	 * @ORM\Id
	 * @ORM\Column(type="integer")
	 * @ORM\GeneratedValue(strategy="AUTO")
	 */
	protected $id;

	public function __construct()
	{
		parent::__construct();
		// your own logic
	}
}