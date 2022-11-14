/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('persona_rol_pertenencia', {
		id_persona_rol_pertenencia: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_persona_rol_pertenencia::regclass)",
			primaryKey: true
		},
		edad_min: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		edad_max: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		edad_recodificada: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_persona_historica_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'persona_historica',
				key: 'id_persona_historica'
			}
		},
		fk_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'pertenencia',
				key: 'id_pertenencia'
			}
		},
		fk_persona_rol_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'persona_rol_pertenencia',
				key: 'id_persona_rol_pertenencia'
			}
		}
	}, {
		tableName: 'persona_rol_pertenencia',
		timestamps: false
	});
};
