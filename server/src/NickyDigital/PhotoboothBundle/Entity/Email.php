<?php

namespace NickyDigital\PhotoboothBundle\Entity;

use Doctrine\ORM\Mapping as ORM;
use Gedmo\Mapping\Annotation as Gedmo;

/**
 * Emails
 *
 * @ORM\Table()
 * @ORM\Entity
 */
class Email
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    private $id;

	// TODO: figure out why Timestampable isn't populating
	/**
	 * @param \DateTime $created
	 *
	 * @Gedmo\Timestampable(on="create")
	 * @ORM\Column(type="datetime", nullable=true)
	 */
	protected $created;

	/**
	 * @ORM\Column(type="string", length=200)
	 */
	protected $email;

	/**
	 * @ORM\ManyToOne(targetEntity="PhotoEvent", inversedBy="emails")
	 */
	private $event;

	public function setCreated($created)
	{
		$this->created = $created;
	}

	public function getCreated()
	{
		return $this->created;
	}

	public function setEmail($email)
	{
		$this->email = $email;
	}

	public function getEmail()
	{
		return $this->email;
	}

	public function setEvent($event)
	{
		$this->event = $event;
	}

	public function getEvent()
	{
		return $this->event;
	}

	/**
	 * @param int $id
	 */
	public function setId($id)
	{
		$this->id = $id;
	}

	/**
	 * @return int
	 */
	public function getId()
	{
		return $this->id;
	}



	
}
